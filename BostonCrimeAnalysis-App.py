import streamlit as st
import pandas as pd
import plotly.express as px
import seaborn as sns
import matplotlib.pyplot as plt

# -------------------------------------------------
# PAGE CONFIG
# -------------------------------------------------
st.set_page_config(page_title="Boston Crime Analysis Dashboard", layout="wide")

# -------------------------------------------------
# TITLE & DESCRIPTION
# -------------------------------------------------
st.markdown(
    "<h1 style='text-align: center; font-weight: bold;'>Boston Crime Analysis Dashboard (2018–2022)</h1>",
    unsafe_allow_html=True
)

st.markdown("""
This interactive dashboard presents an **exploratory analysis of Boston crime incidents**
using data from the **Boston Police Department (2018–2022)**.

📌 Due to GitHub file-size limits, upload the combined CSV file to begin.
""")

st.divider()

# -------------------------------------------------
# FILE UPLOADER
# -------------------------------------------------
uploaded_file = st.file_uploader(
    "📂 Upload Combined_Cr_
