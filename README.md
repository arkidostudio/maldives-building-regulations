# Maldives Building Regulations Hub

A public, unofficial hub for accessing Maldives building regulations, guidance, checking tools and architectural checklists.

Prepared by Arkido Studio.

Translations, transcriptions, summaries and consolidated provisions may have been prepared or synthesized with assistance from AI models. Official Dhivehi publications remain authoritative. Corrections can be reported through this repository's issue tracker.

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
