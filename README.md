# Supply Chain Analytics: Late Deliveries, Profitability, and Demand Forecasting

End-to-end analysis of 180,519 order items from the DataCo supply chain dataset: a normalized SQL Server database, SQL business analysis, a data quality audit, a late-delivery prediction model, and a monthly demand forecast in Python.

**Tools:** SQL Server (T-SQL), Python (pandas, scikit-learn, statsmodels, SciPy, Matplotlib), Jupyter, SQLAlchemy

---

## Business questions

1. Which orders arrive late, and what drives it?
2. Where does the business make and lose money?
3. How much should we expect to sell each month?

## Key findings

- **First Class shipping is late on 100% of orders.** The premium 1-day option is the worst performer; Standard Class has the best on-time rate (about 60%). Overall, 57.3% of completed deliveries were late.
- **Shipping mode is the only real driver of lateness.** Market, customer segment, and payment type show no significant effect (chi-square p = 0.10 to 0.35). A random forest using every available feature (ROC-AUC 0.74) performs no better than a model using shipping mode alone.
- **18.7% of order items lose money**, and those losses (about \$3.88M) give back nearly half of the \$7.85M earned on profitable items. Loss rates are flat across markets and discount levels, so neither explains them.
- **The business is profitable at every category level.** All 51 categories make money overall (Fishing leads with about \$756K profit); only 3 individual products lose money, led by the SOLE E35 Elliptical.
- **Customer segments differ in size, not profitability.** Consumers bring in 52% of revenue, Corporate 30%, and Home Office 18%, all at about a 12% margin.
- **Demand is steady at about \$34,000 a day** (about \$1.04M a month). A simple forecast that adjusts for days in the month (MAPE 4.2%) beat Holt-Winters (6.2%) and SARIMA (4.6%).
- **The data changes structure in October 2017.** Orders drop from about 3 items to exactly 1, and far fewer products are sold. Sales fall about 70% by January 2018, but order counts do not, so this is a data change rather than a collapse in demand.

## Headline numbers

| Metric | Value |
|---|---|
| Order items / orders / customers | 180,519 / 65,752 / 20,652 |
| Date range | January 2015 to January 2018 |
| Gross revenue (before discounts) | \$36.78M |
| Discounts given | \$3.73M (10.1% of gross) |
| Net revenue | \$33.05M |
| Profit | \$3.97M (12.0% of net revenue) |
| Late deliveries (excluding canceled) | 57.3% |

---

## Database design

The raw data arrives as one flat file with 53 columns. I split it into a normalized SQL Server database with primary and foreign keys, plus a seventh table for website clickstream data.

![ER diagram](SQL/supply_chain%20er%20diagram%20.png)

| Table | Rows | One row per |
|---|---|---|
| `departments` | 11 | store department |
| `categories` | 51 | product category |
| `products` | 118 | product |
| `customers` | 20,652 | customer |
| `orders` | 65,752 | order (dates, shipping, delivery status, destination) |
| `order_items` | 180,519 | line item (quantity, price, discount, sales, profit) |
| `page_views` | 432,916 | product page view, September 2017 to January 2018 |

The clickstream logs have no product ID, so `page_views` is linked to `products` by product name; 92% of views match a product in the sales data.

## Project workflow

### 1. SQL analysis ([`SQL/Analyst`](SQL/Analyst))

Business questions answered in T-SQL, including:
- Late delivery rate by shipping mode and market
- Top categories by profit, profit margin by category, and products that lose money
- Revenue and profit by customer segment
- Share of loss-making items, tested against market and discount rate
- Month-over-month sales change (`LAG`), running total (`SUM() OVER`), and top 3 products per market (`ROW_NUMBER` with `PARTITION BY`)

### 2. Data audit ([`NoteBooks/Data_Audit.ipynb`](NoteBooks/Data_Audit.ipynb))

Python connects directly to SQL Server and checks the data before any modeling:
- No duplicates, no orders shipped before they were placed, no invalid quantities, prices, or discounts
- Shipping days recalculated from the dates match the source column on every row
- **Target leakage:** `Delivery_Status` fully determines the late-delivery flag, so it is excluded from modeling
- **Mixed statuses:** "Shipping canceled" combines canceled orders (3,692) and suspected-fraud orders (4,062)
- **Structural break** in October 2017, documented and handled in the forecast
- Profit outliers (as low as -\$4,275) kept, because they are the losses being analyzed

### 3. Late delivery analysis and model ([`NoteBooks/Late_Delivery.ipynb`](NoteBooks/Late_Delivery.ipynb))

- Late rates by group and chi-square tests of significance
- Logistic regression and random forest, compared against a majority-class baseline and a shipping-mode-only model
- Train/test split **by order**, so items from the same order never appear in both sets (a plain random split inflated ROC-AUC from 0.74 to about 0.76)

| Model | Accuracy | ROC-AUC |
|---|---|---|
| Always predict "late" | 0.575 | 0.50 |
| Logistic regression | 0.692 | 0.739 |
| Random forest | 0.691 | 0.740 |
| Shipping mode only | 0.692 | 0.738 |

### 4. Demand forecast ([`NoteBooks/demand_forecast.ipynb`](NoteBooks/demand_forecast.ipynb))

- Modeled January 2015 to September 2017 (33 months), before the structural break
- Showed that the apparent February dip is a days-in-month effect, not seasonality
- Compared five methods on a 6-month holdout, then repeated the test from four rolling starting points

| Method | Holdout MAPE | Rolling avg MAPE |
|---|---|---|
| Daily rate (last 3 months) × days in month | 4.2% | 3.1% |
| Naive (last month) | 4.4% | 4.3% |
| SARIMA | 4.6% | 4.5% |
| Seasonal naive | 6.1% | 4.4% |
| Holt-Winters | 6.2% | 4.5% |

Forecast for October 2017 to March 2018: about \$1.13M per 31-day month, with an approximate 95% range of ±\$117K.

---

## Recommendations

1. **Fix or reset the First Class promise.** It is scheduled for 1 day and never meets it.
2. **Investigate loss-making items with cost data.** Losses are not explained by market, discount, or category, so the cause is likely in costs the dataset does not include.
3. **Plan around about \$34K of sales per day** as the long-run baseline (recent months ran closer to \$36.5K).
4. **Find out why the data changes in October 2017** before relying on any month after September 2017.
5. **Collect carrier, warehouse, and order-volume data** if lateness needs to be predicted beyond shipping mode.

## Limitations

- The dataset appears to be simulated, so some patterns (such as identical top products in every market) are cleaner than real company data.
- Profit is supplied by the source without a cost column, so its calculation cannot be verified.
- The forecast uses only 33 months of history, and the winning method was chosen after seeing results on the same data.

---

## Repository structure

```text
├── Data/                     # Zipped source data (DataCo dataset, column descriptions, access logs)
├── SQL/
│   ├── Structure Tables/     # Build the 6 normalized tables, then the page_views table
│   ├── Analyst/              # Business analysis queries
│   └── supply_chain er diagram .png
├── NoteBooks/
│   ├── Data_Audit.ipynb      # Notebook 1: data quality audit
│   ├── Late_Delivery.ipynb   # Notebook 2: late delivery analysis and model
│   └── demand_forecast.ipynb # Notebook 3: monthly demand forecast
└── README.md
```

## How to reproduce

1. **Get the data.** Unzip the files in `Data/`, or download them from [Kaggle: DataCo Smart Supply Chain for Big Data Analysis](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis).
2. **Set up SQL Server.** Install SQL Server Express and SQL Server Management Studio, and create a database named `supply_chain`.
3. **Import the raw files** with SSMS's Import Flat File wizard: no primary keys, and allow nulls on every column.
4. **Build the tables** by running the scripts in `SQL/Structure Tables/` in order (the 6 core tables first, then `page_views`).
5. **Run the analysis queries** in `SQL/Analyst/`.
6. **Run the notebooks** in order. They need the Microsoft ODBC Driver for SQL Server and these packages:
   ```
   pip install pandas sqlalchemy pyodbc scikit-learn statsmodels scipy matplotlib seaborn
   ```

## Data source

Constante, Fabian; Silva, Fernando; Pereira, António (2019), "DataCo SMART SUPPLY CHAIN FOR BIG DATA ANALYSIS", Mendeley Data, V5, [doi: 10.17632/8gx2fvg2k6.5](https://data.mendeley.com/datasets/8gx2fvg2k6/5).
