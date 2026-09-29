---
title: "U.S. REIT Return Indices"
category: "Research Data"
summary: "Quarterly unlevered and levered total returns for U.S. equity REITs, 1993Q1–2025Q4, free for non-commercial use."
external_url: "https://github.com/wang415705825/Real-Estate-Returns"
order: 0
social_image: /assets/images/reit-return-indices/share-card.png
social_image_alt: "U.S. REIT Return Indices, 1993–2025: 9.62% a year for REIT stocks and 8.34% a year for REIT assets, with a chart of the growth of one dollar since 1993."
---

<p class="lede">Quarterly total-return indices for U.S. equity REITs in two versions: the
levered returns earned by REIT shareholders and the unlevered returns earned by the assets
behind them.</p>

<figure class="data-figure">
  <img src="{{ '/assets/images/reit-return-indices/cumulative-returns.png' | relative_url }}" width="1600" height="970" loading="lazy" alt="Line chart of the growth of one dollar invested at the start of 1993 in value-weighted U.S. equity REITs, log scale. The levered (REIT stock) index ends at 20.74 and the unlevered (REIT assets) index at 14.04; the gap from leverage widens over time, and both fall sharply in 2008–2009.">
  <figcaption>Value-weighted, all equity REITs. Unlevered returns follow the de-levering
  method of Ling and Naranjo (2015).</figcaption>
</figure>

## What's included

- **Coverage:** 1993Q1–2025Q4, quarterly, for all equity REITs, core and non-core property
  types, and 14 S&P Global property types.
- **Series:** unlevered and levered total returns, value- and equal-weighted, with REIT counts
  for every cell.
- **Method:** each REIT's unlevered return is the capital-weighted average of the returns on
  its equity, debt and preferred stock (Ling and Naranjo, 2015).
- **Validation:** correlation of 0.993 with the Ling and Naranjo (2015) unlevered core index
  over 1993Q1–2012Q4, and 0.986 with the FTSE Nareit All Equity REITs index over
  1993Q1–2025Q4.

<figure class="data-figure">
  <img src="{{ '/assets/images/reit-return-indices/property-type-returns.png' | relative_url }}" width="1600" height="1029" loading="lazy" alt="Dot chart of annualized value-weighted returns, 1993–2025, unlevered versus levered, for all equity REITs and six property types. Levered minus unlevered: all equity REITs +1.28 percentage points, Multifamily +1.91, Industrial +1.70, Health Care +1.54, Shopping Center +0.74, Office +0.03 and Diversified −0.17.">
  <figcaption>Annualized returns by property type, 1993–2025, value-weighted.</figcaption>
</figure>

## Download

- [Main series](https://github.com/wang415705825/Real-Estate-Returns/blob/main/data/reit_return_indices.csv)
  (CSV): all equity REITs, core and non-core
- [By property type](https://github.com/wang415705825/Real-Estate-Returns/blob/main/data/reit_returns_by_property_type.csv)
  (CSV)
- [Excel workbook](https://github.com/wang415705825/Real-Estate-Returns/blob/main/data/REIT_Return_Indices.xlsx)
  with notes and summary statistics
- [Methodology](https://github.com/wang415705825/Real-Estate-Returns/blob/main/docs/methodology.md)
  and [construction code](https://github.com/wang415705825/Real-Estate-Returns/tree/main/pipeline)

## How to cite

Ling, D. C., Wang, C., and Zhou, T. (2022). Asset productivity, local information diffusion,
and commercial real estate returns. *Real Estate Economics*, 50(1), 89–121.
<https://doi.org/10.1111/1540-6229.12354>

Ling, D. C., and Naranjo, A. (2015). Returns and information transmission dynamics in public
and private real estate markets. *Real Estate Economics*, 43(1), 163–208.
<https://doi.org/10.1111/1540-6229.12069>

## License

Data and documentation are released under
[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) (attribution,
non-commercial use) and the code under the MIT License. The series are aggregates computed
from CRSP, Compustat and S&P Global Market Intelligence; no vendor data are included.
Questions and corrections are welcome as
[GitHub issues](https://github.com/wang415705825/Real-Estate-Returns/issues).
