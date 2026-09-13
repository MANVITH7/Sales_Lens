# Power BI Build Guide — Sales Lens Dashboard

This guide assumes you have **never opened Power BI before**. Every step names the exact menu, button, or panel to click. Follow it top to bottom.

The 5 CSV files you'll import are already generated for you in `data/cleaned/`:

| File | What it's for |
|---|---|
| `yearly_regional_sales.csv` | Regional YoY sales trend |
| `top_products_by_category.csv` | Top products by category |
| `customer_segment_performance.csv` | Customer segment breakdown |
| `monthly_sales_trend.csv` | Monthly sales trend line |
| `discount_impact_analysis.csv` | Discount vs. profit margin |

---

## 0. Installing Power BI Desktop

Power BI Desktop is **free**, but it is **Windows-only**.

### If you're on Windows
1. Go to `powerbi.microsoft.com/desktop` in your browser.
2. Click the **Download free** button.
3. This opens the Microsoft Store app page for Power BI Desktop. Click **Get** (or **Install**).
4. Once installed, open it from your Start Menu — search "Power BI Desktop" and click it.
5. On first launch, a sign-in screen may appear. Click **"Sign in"** if you have a free Microsoft/Power BI account, or look for a small "X" or "Skip" option to close the dialog — you don't need an account to build a local dashboard.

### If you're on a Mac (like this project)
Power BI Desktop does not run natively on macOS. You have two options:

**Option A — Windows VM (recommended for the full desktop experience):**
Run Windows inside a virtual machine app (e.g., Parallels Desktop, VMware Fusion, or the free UTM) and install Power BI Desktop inside it following the Windows steps above. This gives you the full experience described in this guide.

**Option B — Power BI Service (in-browser, no install):**
1. Go to `app.powerbi.com` in your browser and sign in with (or create) a free Microsoft account.
2. Click **"My workspace"** in the left navigation panel.
3. Click **"New"** → **"Report"** → **"Upload a file"**, then upload your CSVs one at a time.
4. The browser version has slightly different menu names than described below (e.g., "Data" pane instead of "Fields" pane in a couple of spots), but the visual-building steps are conceptually the same — you'll still drag fields into an X-axis/Y-axis/Values box on the right.

The rest of this guide describes **Power BI Desktop** (Option A or native Windows), since that's the standard tool for a portfolio project. If you use Option B, treat every "Home ribbon" instruction as "the top toolbar" instead.

---

## 1. Importing the 5 CSV files

Open Power BI Desktop. You'll see a mostly blank screen with a ribbon (toolbar) across the top.

**Repeat this exact process 5 times, once per file:**

1. In the **Home** ribbon (the row of icons/buttons at the top), find and click **"Get Data"** (it has a small database-cylinder icon, usually near the top-left).
2. A dropdown/dialog appears. Click **"Text/CSV"**.
3. A file browser window opens. Navigate to your project's `data/cleaned/` folder.
4. Click on the first file — **`yearly_regional_sales.csv`** — then click **"Open"**.
5. A preview window pops up showing the data. Confirm it looks right (column headers like `region`, `order_year`, etc. should be in the first row).
6. Click **"Load"** in the bottom-left of that preview window (not "Transform Data" — we don't need to change anything).
7. Wait a few seconds for it to load. It will finish silently — you'll just see the ribbon become active again.

Now repeat steps 1–6 for the other four files:
- `top_products_by_category.csv`
- `customer_segment_performance.csv`
- `monthly_sales_trend.csv`
- `discount_impact_analysis.csv`

### Confirm all 5 loaded correctly
On the right-hand side of the screen, find the **Fields** pane (it's usually the rightmost vertical panel, labeled "Fields" with a small table/grid icon). You should see 5 entries listed there, one per CSV, each with a small table icon and expandable to show its columns (click the small arrow/triangle next to a name to expand it). If you see all 5, you're ready for the next section.

---

## 2. Building the visuals

You build visuals on the big blank white/gray area in the middle of the screen — this is the **canvas**.

On the right side of the screen you should see two panels stacked vertically:
- **Visualizations pane** (top-right) — a grid of small icons, each representing a chart type (bar chart, line chart, pie chart, card, table, etc.). Hovering over an icon shows its name as a tooltip.
- **Fields pane** (below it) — your 5 loaded tables, each expandable to show columns.

### Visual 1 — Regional YoY Sales Trend (Line Chart)

1. Click anywhere on the empty canvas first to make sure nothing else is selected.
2. In the **Visualizations pane**, find the **Line Chart** icon — it looks like a simple upward zigzag line (a single squiggly diagonal line icon, distinct from the bar chart's vertical bars). Click it once. An empty chart placeholder appears on the canvas.
3. With that chart still selected (it should have a border around it), expand **`yearly_regional_sales`** in the Fields pane by clicking the small arrow next to it.
4. Drag the field **`order_year`** from the Fields pane onto the **"X-axis"** box in the Visualizations pane (you'll see box labels like "X-axis", "Y-axis", "Legend" appear once the chart type is selected — they're below the chart-type icons).
5. Drag **`total_sales`** onto the **"Y-axis"** box.
6. Drag **`region`** onto the **"Legend"** box. This splits the line into one line per region, so you can compare regions on the same chart.
7. Resize the chart by clicking it once and dragging the corner handle, so it takes up roughly the top-left third of the canvas.

### Visual 2 — Top Products by Category (Bar Chart)

1. Click an empty part of the canvas to deselect the previous chart.
2. In the Visualizations pane, find the **Clustered Bar Chart** icon — it looks like 3 horizontal bars of different lengths stacked on top of each other. Click it.
3. Expand **`top_products_by_category`** in the Fields pane.
4. Drag **`product_name`** onto the **"Y-axis"** box (for a horizontal bar chart, categories go on the Y-axis and values go on the X-axis).
5. Drag **`total_sales`** onto the **"X-axis"** box.
6. Drag **`category`** onto the **"Legend"** box, so each category's products are color-coded.
7. This chart will look cluttered with 30 products — that's expected. Click the chart, then in the Visualizations pane find the **"Filters"** icon (a funnel shape, usually a separate pane below or beside Visualizations — labeled "Filters on this visual"). Drag **`sales_rank_in_category`** into the filter area, set the filter type dropdown to **"is less than or equal to"**, type **5**, and click **"Apply filter"**. This narrows it to the top 5 per category.
8. Position this chart in the top-right third of the canvas.

### Visual 3 — Customer Segment Breakdown (Donut Chart)

1. Click empty canvas space to deselect.
2. In the Visualizations pane, find the **Donut Chart** icon — a circle with a hole in the middle, split into colored wedges. Click it.
3. Expand **`customer_segment_performance`** in the Fields pane.
4. Drag **`segment`** onto the **"Legend"** box.
5. Drag **`total_sales`** onto the **"Values"** box.
6. Position this chart in the bottom-left area of the canvas.

### Visual 4 — Monthly Sales Trend (Line Chart)

1. Click empty canvas space to deselect.
2. In the Visualizations pane, click the **Line Chart** icon again (same icon as Visual 1 — you can have multiple line charts).
3. Expand **`monthly_sales_trend`** in the Fields pane.
4. Drag **`year_month`** onto the **"X-axis"** box.
   - Important: click the small dropdown arrow that appears on the `year_month` field once it's in the X-axis box, and make sure it says **"Don't summarize"** rather than "Count" — since this is a text label (like "2014-01"), not a number to be summed.
5. Drag **`total_sales`** onto the **"Y-axis"** box.
6. Position this chart in the bottom-middle of the canvas.

### Visual 5 — Discount vs. Profit Margin (Clustered Column Chart)

1. Click empty canvas space to deselect.
2. In the Visualizations pane, find the **Clustered Column Chart** icon — it looks like 3 vertical bars of different heights (this is the vertical version of Visual 2's horizontal bar chart). Click it.
3. Expand **`discount_impact_analysis`** in the Fields pane.
4. Drag **`discount_bucket`** onto the **"X-axis"** box.
5. Drag **`avg_profit_margin_pct`** onto the **"Y-axis"** box.
6. Position this chart in the bottom-right area of the canvas.

At this point you have 5 visuals arranged roughly in a 2-row grid. Section 4 below covers final layout polish.

---

## 3. Adding DAX Measures (KPI calculations)

A **measure** is a custom calculation you write using Power BI's formula language, DAX. We'll add 3 measures as KPI cards at the top of the dashboard.

### How to create a measure (do this 3 times, once per formula below)

1. In the **Fields** pane, click on the table name **`yearly_regional_sales`** once to select it (just click the table name itself, not a column inside it).
2. Go to the **Home** ribbon at the top of the screen. Find and click **"New Measure"** (it's usually grouped near "New Table" / "New Column" — icons that suggest adding data structures).
3. A formula bar appears near the top of the canvas — an editable text box where you type DAX code.
4. Type or paste the formula exactly as written below, then press **Enter** on your keyboard to confirm it.

### Measure 1 — YoY Growth %

```dax
YoY Growth % = AVERAGE(yearly_regional_sales[yoy_sales_growth_pct])
```

### Measure 2 — Profit Margin %

Select the **`customer_segment_performance`** table in the Fields pane first (per step 1 above), then create this measure:

```dax
Profit Margin % =
DIVIDE(
    SUM(customer_segment_performance[total_profit]),
    SUM(customer_segment_performance[total_sales]),
    0
)
```

### Measure 3 — Running Total Sales

Select the **`monthly_sales_trend`** table first, then create this measure:

```dax
Running Total Sales =
CALCULATE(
    SUM(monthly_sales_trend[total_sales]),
    FILTER(
        ALLSELECTED(monthly_sales_trend[year_month]),
        monthly_sales_trend[year_month] <= MAX(monthly_sales_trend[year_month])
    )
)
```

### Measure 4 — Total Sales (a simple base measure, useful for KPI cards)

Select the **`monthly_sales_trend`** table first, then create this measure:

```dax
Total Sales = SUM(monthly_sales_trend[total_sales])
```

### Adding KPI cards using these measures

1. Click empty canvas space at the very top of your dashboard (above the 5 charts — you may need to shrink the charts down slightly first, or just place cards and drag charts down afterward).
2. In the Visualizations pane, find the **Card** icon (labeled "Card" — looks like a single rectangle with a big number in it, sometimes shown as "New Card" in current versions).
3. With the empty card visual selected, expand the **`monthly_sales_trend`** table (where `Total Sales` and `Running Total Sales` live) in the Fields pane and drag **`Total Sales`** (the measure you created — it has a calculator icon next to it, different from a regular column icon) into the card's **"Fields"** box.
4. Repeat: add 2 more Card visuals for **`Running Total Sales`** and, from the `customer_segment_performance` table, **`Profit Margin %`**.
5. Arrange these 3 cards in a horizontal row along the top of the canvas.

---

## 4. Arranging the final layout

A clean single-page dashboard reads top-to-bottom in order of importance:

```
┌─────────────┬─────────────┬─────────────┐
│  Total Sales│Running Total│Profit Margin│   <- Row 1: KPI cards
├─────────────┴──────┬──────┴─────────────┤
│  Regional YoY Trend │  Top Products      │   <- Row 2: trend charts
│  (Line Chart)       │  (Bar Chart)       │
├──────────┬──────────┴──────┬─────────────┤
│ Segment  │  Monthly Trend  │  Discount   │   <- Row 3: breakdowns
│ (Donut)  │  (Line Chart)   │  Impact     │
└──────────┴─────────────────┴─────────────┘
```

To move a visual: click it once to select it, then click and drag from the middle of the chart (not the edges) to reposition it. To resize: click it once, then drag one of the small square handles that appear at its corners/edges.

Optional polish:
1. Click on the canvas background (not any chart) so nothing is selected.
2. In the Visualizations pane, look for a **paint-roller icon** — this is the **Format** pane for the whole page. Click it, then find **"Canvas background"**, and you can set a light gray or white background.
3. Give the dashboard a title: in the **Insert** ribbon at the top, click **"Text Box"**, click-drag to draw a box at the very top of the canvas, and type **"Sales Lens — Retail KPI Dashboard"**.

---

## 5. Saving the file

1. Go to the **File** menu (top-left corner).
2. Click **"Save As"**.
3. Navigate to this project's `powerbi/` folder (the same folder this guide is in).
4. In the filename box, type: **`retail_dashboard`**
5. Click **"Save"**. Power BI automatically adds the `.pbix` extension, so the final file will be `powerbi/retail_dashboard.pbix`.

---

## 6. Exporting a screenshot/PDF for the README

**Option A — Export to PDF (built into Power BI):**
1. Go to **File** → **Export** → **Export to PDF**.
2. Choose a save location — save it as `powerbi/dashboard_screenshot.pdf`.
3. Click **Export**.

**Option B — Plain screenshot:**
- **Windows:** press `Win + Shift + S`, drag to select the dashboard area, then paste (Ctrl+V) into an image editor or directly into a new file, and save as `powerbi/dashboard_screenshot.png`.
- **Mac (if using Power BI Service in browser):** press `Cmd + Shift + 4`, drag to select the area, and it saves a `.png` to your Desktop automatically — move it into `powerbi/dashboard_screenshot.png`.

Once you have this image, come back and update the README's "Dashboard Screenshot" section to point to it (Phase 7 already sets up a placeholder for this).

---

## You're done

You now have `powerbi/retail_dashboard.pbix` — a real, working Power BI dashboard built from your own SQL views. Add it to the project folder and let me know when you'd like to commit it.
