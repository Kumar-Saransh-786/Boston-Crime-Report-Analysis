
import streamlit as st
import pandas as pd
import plotly.express as px
import seaborn as sns
import matplotlib.pyplot as plt

# -----------------------------
# PAGE CONFIG
# -----------------------------
st.set_page_config(page_title="Boston Crime Analysis Dashboard", layout="wide")

# -----------------------------
# LOAD DATA
# -----------------------------
@st.cache_data
def load_data():
    return pd.read_csv("Combined_Crime_Incident_Reports_2018_2022.csv")

df = load_data()

# -----------------------------
# TITLE & DESCRIPTION
# -----------------------------
st.title("🚔 Boston Crime Analysis Dashboard (2018–2022)")

st.markdown("""
This interactive dashboard analyzes **Boston crime incidents (2018–2022)** using data from the
Boston Police Department.

**Objectives**
- Analyze crime patterns across districts  
- Understand temporal trends (day, hour, month)  
- Identify shooting hotspots  
- Support data-driven public safety insights  
""")

st.divider()

# -----------------------------
# SIDEBAR
# -----------------------------
section = st.sidebar.radio(
    "Select Analysis Section",
    [
        "Overview",
        "Crime Distribution",
        "Temporal Trends",
        "Shootings Analysis",
        "Statistical Insights"
    ]
)

# -----------------------------
# OVERVIEW
# -----------------------------
if section == "Overview":
    col1, col2, col3 = st.columns(3)
    col1.metric("Total Incidents", f"{len(df):,}")
    col2.metric("Total Shootings", int(df['SHOOTING'].sum()))
    col3.metric("Districts", df['DISTRICT_NAME'].nunique())

# -----------------------------
# CRIME DISTRIBUTION
# -----------------------------
elif section == "Crime Distribution":
    st.subheader("Top 10 Crimes in Boston")

    crime_counts = (
        df[df['OFFENSE_CODE_GROUP'] != "Other"]
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

# -----------------------------
# TEMPORAL TRENDS
# -----------------------------
elif section == "Temporal Trends":
    year = st.selectbox("Select Year", sorted(df['YEAR'].unique()))

    st.subheader("Incidents by Day of Week")
    day_df = df[df['YEAR'] == year].groupby("DAY_OF_WEEK").size().reset_index(name="Count")
    st.plotly_chart(px.line(day_df, x="DAY_OF_WEEK", y="Count", markers=True),
                    use_container_width=True)

    st.subheader("Incidents by Hour")
    hour_df = df[df['YEAR'] == year].groupby("HOUR").size().reset_index(name="Count")
    st.plotly_chart(px.line(hour_df, x="HOUR", y="Count", markers=True),
                    use_container_width=True)

# -----------------------------
# SHOOTINGS ANALYSIS
# -----------------------------
elif section == "Shootings Analysis":
    st.subheader("Shootings by District")

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

# -----------------------------
# STATISTICAL INSIGHTS
# -----------------------------
elif section == "Statistical Insights":
    st.subheader("Correlation Matrix")

    numeric_df = df.select_dtypes(include="number")
    corr = numeric_df.corr()

    fig, ax = plt.subplots(figsize=(10, 6))
    sns.heatmap(corr, cmap="coolwarm", ax=ax)
    st.pyplot(fig)
