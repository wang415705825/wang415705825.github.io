# Chongyu (Michael) Wang — Academic Website

The source for [wang415705825.github.io](https://wang415705825.github.io), built as an extensible Jekyll site and deployed through GitHub Pages. Research, news, and resources live in structured Markdown; shared layouts keep every current and future page visually consistent.

## Update content

Most routine updates do not require editing HTML.

- **Research:** add one file to `_research/` with `title`, `slug`, `permalink`, `authors`, `year`, `type`, `status`, `topics`, `featured`, and a concise verified `summary`; `venue`, `links`, `awards`, and `funding` are optional. Use one of `publication`, `working-paper`, or `work-in-progress` for `type`. A paper at `_research/example.md` should use `/research/example/` as its permalink.
- **Research statement:** edit the narrative, theme order, and paper slugs in `_data/research_statement.yml`. Paper titles, years, statuses, and summaries are resolved from `_research/`; do not duplicate them in the statement data.
- **News:** `_news/` is retained as source data but is not generated or displayed. Do not restore News without an explicit request.
- **Resources:** add a file to `_resources/` with `title`, `category`, `summary`, `order`, and an optional `external_url`. Every resource automatically receives a page at `/resources/<filename>/`.
- **Profile and CV:** edit `_data/profile.yml` for public profile fields. The retained CV file is excluded from the build and must remain unlinked unless its publication is explicitly requested.
- **Appointments, teaching, service, and honors:** their YAML files are retained as source data, but their public sections are disabled. Update source facts if needed without restoring those sections. Code projects remain public through `_data/code.yml`.
- **Navigation:** edit `_data/navigation.yml` when a new top-level page should appear in the shared header.

To add a standalone subpage, create a Markdown file with YAML front matter. The shared page layout is applied automatically. For example:

```markdown
---
title: New Page
permalink: /new-page/
---

Page content goes here.
```

The default layout automatically supplies the site header, footer, metadata, and design system.

## Review and publishing workflow

1. Make changes on a branch and open a pull request.
2. Cite the source for factual updates. Use the current CV first, then the FSU profile, journal/DOI/SSRN records, and finally the legacy Google Site.
3. Automated checks validate structured content, build all routes, and check rendered internal links.
4. Review the preview and merge only after the content is confirmed. Merging to `main` deploys the site through the official GitHub Pages Actions flow.

Monthly maintenance should create a **draft pull request only when verified changes exist**. It must never infer a paper status, resolve a source conflict silently, auto-merge, or publish “To be added” text. Dependabot checks the Ruby and GitHub Actions dependencies monthly; those pull requests also require review.

## Local preview

Ruby and Bundler are required.

```sh
bundle install
bundle exec jekyll serve --livereload
```

Then open `http://127.0.0.1:4000`. Before submitting a change, run:

```sh
ruby scripts/validate_content.rb
JEKYLL_ENV=production bundle exec jekyll build --strict_front_matter
bundle exec htmlproofer ./_site --disable-external
```

## Design provenance

The site takes broad visual inspiration from the academic-homepage genre and the [`w-r-s/academic-homepage-template`](https://github.com/w-r-s/academic-homepage-template) reference shared during planning. Its implementation, styling, and locally hosted assets were created independently; no source code or imagery was copied from that unlicensed repository.
