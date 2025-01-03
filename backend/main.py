from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
import json
from typing import Optional
import pandas as pd
import numpy as np
from io import BytesIO
import matplotlib.pyplot as plt
import scipy.stats as stats
import base64
import os

app = FastAPI()
GRADES_DIR = os.path.join(os.path.expanduser("~"), "Documents", "GradingSystem", "Processed")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def ensure_grades_directory():
    if not os.path.exists(GRADES_DIR):
        os.makedirs(GRADES_DIR)

def validate_dataframe(df):
    required_columns = ['RegNo', 'Marks']
    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")

def calculate_relative_grades(df, distribution):
    validate_dataframe(df)
    df['z_score'] = (df['Marks'] - df['Marks'].mean()) / df['Marks'].std()
    grades = []
    for z in df['z_score']:
        if z >= 1.0:
            grades.append("A")
        elif z >= 0.0:
            grades.append("B")
        elif z >= -1.0:
            grades.append("C")
        elif z >= -2.0:
            grades.append("D")
        else:
            grades.append("F")
    df['Grade'] = grades
    return df

def calculate_absolute_grades(df, thresholds):
    validate_dataframe(df)
    grades = []
    for mark in df['Marks']:
        if mark >= thresholds["A"]:
            grades.append("A")
        elif mark >= thresholds["B"]:
            grades.append("B")
        elif mark >= thresholds["C"]:
            grades.append("C")
        elif mark >= thresholds["D"]:
            grades.append("D")
        else:
            grades.append("F")
    df['Grade'] = grades
    return df

def compute_statistics(df):
    return {
        "mean": float(df['Marks'].mean()),
        "median": float(df['Marks'].median()),
        "std_dev": float(df['Marks'].std()),
        "mode": float(df['Marks'].mode()[0])
    }

def create_histogram(df):
    plt.figure()
    plt.hist(df['Marks'], bins=10, color='blue', alpha=0.7)
    plt.title('Marks Distribution')
    plt.xlabel('Marks')
    plt.ylabel('Frequency')
    plt.savefig('histogram.png')
    plt.close()

def create_bell_curve(df):
    plt.figure()
    marks = df['Marks']
    mean = marks.mean()
    std = marks.std()
    x = np.linspace(mean - 4*std, mean + 4*std, 100)
    y = stats.norm.pdf(x, mean, std)
    plt.plot(x, y)
    plt.title('Normal Distribution of Marks')
    plt.xlabel('Marks')
    plt.ylabel('Probability Density')
    plt.grid(True)
    plt.savefig('bell_curve.png')
    plt.close()

def create_grade_comparison(df, type, thresholds=None):
    plt.figure(figsize=(10, 6))
    relative_grades = calculate_relative_grades(df.copy(), None)['Grade']
    absolute_grades = calculate_absolute_grades(df.copy(), thresholds or {"A": 90, "B": 80, "C": 70, "D": 60, "F": 0})['Grade']
    
    grades = ['A', 'B', 'C', 'D', 'F']
    relative_counts = [len(relative_grades[relative_grades == grade]) for grade in grades]
    absolute_counts = [len(absolute_grades[absolute_grades == grade]) for grade in grades]
    
    x = np.arange(len(grades))
    width = 0.35
    plt.bar(x - width/2, relative_counts, width, label='Relative')
    plt.bar(x + width/2, absolute_counts, width, label='Absolute')
    plt.xlabel('Grades')
    plt.ylabel('Number of Students')
    plt.title('Grade Distribution Comparison')
    plt.xticks(x, grades)
    plt.legend()
    plt.savefig('grade_comparison.png')
    plt.close()

def encode_image_to_base64(file_path):
    with open(file_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

@app.post("/process-grading/")
async def process_grading(
    file: UploadFile,
    type: str = Form(...),
    distribution: Optional[str] = Form(None),
    thresholds: Optional[str] = Form(None)
):
    try:
        file_content = await file.read()
        df = pd.read_csv(BytesIO(file_content)) if file.filename.endswith('.csv') \
            else pd.read_excel(BytesIO(file_content))
        
        validate_dataframe(df)
        
        if type == "relative":
            df = calculate_relative_grades(df, json.loads(distribution) if distribution else None)
        else:
            df = calculate_absolute_grades(df, json.loads(thresholds) if thresholds else None)
        
        ensure_grades_directory()
        filename_without_ext = os.path.splitext(file.filename)[0]
        output_filename = f"{filename_without_ext}_graded.csv"
        output_path = os.path.join(GRADES_DIR, output_filename)
        df.to_csv(output_path, index=False)
        
        stats = compute_statistics(df)
        create_histogram(df)
        create_bell_curve(df)
        create_grade_comparison(df, type, json.loads(thresholds) if thresholds else None)
        
        histogram_base64 = encode_image_to_base64('histogram.png')
        bell_curve_base64 = encode_image_to_base64('bell_curve.png')
        comparison_base64 = encode_image_to_base64('grade_comparison.png')
        
        for temp_file in ['histogram.png', 'bell_curve.png', 'grade_comparison.png']:
            if os.path.exists(temp_file):
                os.remove(temp_file)
        
        print(f"\nProcessed file saved to: {output_path}")
        
        return {
            "status": "success",
            "filename": file.filename,
            "grading_type": type,
            "statistics": stats,
            "grades": {
                "RegNo": df['RegNo'].astype(str).to_dict(),
                "Marks": df['Marks'].to_dict(),
                "Grade": df['Grade'].to_dict()
            },
            "visualizations": {
                "histogram": histogram_base64,
                "bell_curve": bell_curve_base64,
                "grade_comparison": comparison_base64
            }
        }
    
    except Exception as e:
        print(f"\nError occurred: {str(e)}\n")
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)