# Maldives Building Regulation Navigator

A static navigator, rule checker and architectural checklist for the Maldives regulation on building in islands or lagoons without planning rules.

Prepared by Arkido Studio.

## Local preview

Run this from the project directory:

```sh
python3 -m http.server 8001
```

Then open `http://localhost:8001`.

## Deploy with GitHub and Vercel

1. Create an empty GitHub repository.
2. Commit this project and push it to that repository.
3. In Vercel, choose **Add New → Project** and import the GitHub repository.
4. Keep **Framework Preset** set to **Other** and leave the build command empty.
5. Deploy. `vercel.json` routes the site root to `building-reg.html`.

This project has no build step and no server-side dependencies.
