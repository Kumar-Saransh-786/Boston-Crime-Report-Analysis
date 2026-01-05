
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
st.title("🚔 Boston Crime Analysis Dashboard (2018–2022)")

st.markdown("""
This interactive dashboard presents an **exploratory analysis of Boston crime incidents**
using data from the **Boston Police Department (2018–2022)**.

📌 **Note:** Due to GitHub file-size limits, please upload the combined CSV file to begin.
""")

st.divider()

# -------------------------------------------------
# FILE UPLOADER
# -------------------------------------------------
uploaded_file = st.file_uploader(
    "📂 Upload Combined_Crime_Incident_Reports_2018_2022.csv",
    type=["csv"]
)

if uploaded_file is None:
    st.warning("Please upload the CSV file to load the dashboard.")
    st.stop()

@st.cache_data
def load_data(file):
    return pd.read_csv(file, low_memory=False)

with st.spinner("Loading crime data..."):
    df = load_data(uploaded_file)

# -------------------------------------------------
# SAFETY CHECKS & FEATURE CREATION
# -------------------------------------------------

# Create DISTRICT_NAME if it doesn't exist (raw CSV case)
if "DISTRICT_NAME" not in df.columns and "DISTRICT" in df.columns:
    district_mapping = {
        "D4": "South End",
        "A7": "East Boston",
        "D14": "Brighton",
        "B3": "Mattapan",
        "A1": "Downtown",
        "C6": "South Boston",
        "A15": "Charlestown",
        "E5": "West Roxbury",
        "E18": "Hyde Park",
        "B2": "Roxbury",
        "C11": "Dorchester",
        "E13": "Jamaica Plain",
        "External": "External"
    }
    df["DISTRICT_NAME"] = df["DISTRICT"].map(district_mapping)

# Ensure SHOOTING column is numeric
if df["SHOOTING"].dtype == object:
    df["SHOOTING"] = df["SHOOTING"].fillna(0)
    df["SHOOTING"] = df["SHOOTING"].apply(lambda x: 1 if str(x).upper() == "Y" else 0)

st.success("Data loaded and validated successfully!")

# -------------------------------------------------
# SIDEBAR NAVIGATION
# -------------------------------------------------
section = st.sidebar.radio(
    "📌 Select Analysis Section",
    [
        "Overview",
        "Crime Distribution",
        "Temporal Trends",
        "Shootings Analysis",
        "Statistical Insights"
    ]
)

# -------------------------------------------------
# OVERVIEW
# -------------------------------------------------
if section == "Overview":
    col1, col2, col3 = st.columns(3)

    col1.metric("Total Incidents", f"{len(df):,}")
    col2.metric("Total Shootings", int(df["SHOOTING"].sum()))
    col3.metric("Districts", df["DISTRICT_NAME"].nunique())

# -------------------------------------------------
# CRIME DISTRIBUTION
# -------------------------------------------------
elif section == "Crime Distribution":
    st.subheader("🔝 Top 10 Crimes in Boston")

    if "OFFENSE_CODE_GROUP" in df.columns:
        crime_counts = (
            df[df["OFFENSE_CODE_GROUP"].notna()]
            .groupby("OFFENSE_CODE_GROUP")
            .size()
            .reset_index(name="Count")
            .sort_values("Count", ascending=False)
            .head(10)
        )

        fig = px.bar(
            crime_counts,
            x="OFFENSE_CODE_GROUP",
            y="Count",
            color="OFFENSE_CODE_GROUP"
        )
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.warning("OFFENSE_CODE_GROUP column not found in dataset.")

# -------------------------------------------------
# TEMPORAL TRENDS
# -------------------------------------------------
elif section == "Temporal Trends":
    year = st.selectbox("Select Year", sorted(df["YEAR"].dropna().unique()))

    st.subheader("📅 Incidents by Day of Week")
    day_df = (
        df[df["YEAR"] == year]
        .groupby("DAY_OF_WEEK")
        .size()
        .reset_index(name="Count")
    )
    st.plotly_chart(px.line(day_df, x="DAY_OF_WEEK", y="Count", markers=True),
                    use_container_width=True)

    st.subheader("⏰ Incidents by Hour")
    hour_df = (
        df[df["YEAR"] == year]
        .groupby("HOUR")
        .size()
        .reset_index(name="Count")
    )
    st.plotly_chart(px.line(hour_df, x="HOUR", y="Count", markers=True),
                    use_container_width=True)

# -------------------------------------------------
# SHOOTINGS ANALYSIS
# -------------------------------------------------
elif section == "Shootings Analysis":
    st.subheader("🔫 Shootings by District")

    shooting_df = (
        df.groupby("DISTRICT_NAME")["SHOOTING"]
        .sum()
        .reset_index()
        .sort_values("SHOOTING", ascending=False)
    )

    st.plotly_chart(
        px.bar(shooting_df, x="DISTRICT_NAME", y="SHOOTING"),
        use_container_width=True
    )

# -------------------------------------------------
# STATISTICAL INSIGHTS
# -------------------------------------------------
elif section == "Statistical Insights":
    st.subheader("📊 Correlation Matrix")

    numeric_df = df.select_dtypes(include="number")
    corr = numeric_df.corr()

    fig, ax = plt.subplots(figsize=(10, 6))
    sns.heatmap(corr, cmap="coolwarm", ax=ax)
    st.pyplot(fig)
