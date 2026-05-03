# E-commerce Funnel & Revenue Analysis

## Project Overview

This project analyzes user funnel behavior, traffic source performance, and revenue trends using the TheLook Ecommerce public dataset available in Google BigQuery.

The objective was to understand:

* how users move through the ecommerce funnel
* which traffic sources contribute the most revenue
* how revenue evolves over time

## Tools Used

* SQL (Google BigQuery)
* Tableau Public

## Key Insights

* User journeys were non-linear, with many users entering directly at product pages rather than following a strict homepage-first path.
* Email and Adwords emerged as the strongest traffic sources in terms of total revenue.
* Average order value remained relatively stable across channels, indicating that revenue differences were primarily driven by order volume.
* Revenue showed consistent long-term growth, suggesting sustained business expansion over time.

## Recommendations

* Strengthen organic acquisition to reduce dependence on top-performing paid and email channels.
* Investigate deeper funnel entry behavior to better understand non-linear user journeys.
* Monitor monthly revenue patterns to identify seasonal opportunities and slower-growth periods.

## SQL Queries

The full SQL workflow used for the analysis is available here:

[Funnel_Analysis.sql](Funnel_Analysis.sql)

## Dashboard

![E-commerce Funnel Dashboard](funnel-analysis-dasboard.png)

## Dataset

This project uses the public TheLook Ecommerce dataset from Google BigQuery.
