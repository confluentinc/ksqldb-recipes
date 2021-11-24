# ksqlDB Recipes

This repository contains a collection of ksqlDB Recipes.

#### How to contribute

If you'd like to contribute a recipe, please submit a Pull Request.
The content of that PR should follow the template established by existing recipes.
Browse through any recipe in https://github.com/confluentinc/ksqldb-recipes/tree/master/docs for more details, but it effectively boils down to:

1. Select the `docs/<industry>` folder for the appropriate industry, or create a new one
2. Create a new subfolder for the new recipe, e.g. `docs/<industry>/<new-recipe-name>`
3. Copy the contents of the [template](template) directory as the basis for your new recipe

- index.md: explain the use case, why it matters, add a graphic if available
- source.sql: SQL commands to create source connectors to pull from a real end system -- for ksqlDB-connect integration
- source.json: JSON configuration to create source connectors to pull from a real end system
- manual.sql: SQL commands to insert mock data into Kafka topics (if real end system does not exist)
- process.sql: this is the core of the recipe, the SQL commands that correspond to the event stream processing
- sink.sql: (optional) SQL commands to create sink connectors to push results to a real end system -- for ksqlDB-connect integration
- sink.json: (optional) JSON configuration to create sink connectors to push results to a real end system


#### Build locally

To view your new recipes locally, you can build a local version of the recipes site with `mkdocs`.

- Install `mkdocs` (https://www.mkdocs.org/)

    On macOS, you can use Homebrew:
    ```bash
    brew install mkdocs
    pip3 install mkdocs pymdown-extensions
    pip3 install mkdocs-material
    pip3 install mkdocs-exclude
    ```

- Build and serve a local version of the site. In this step, `mkdocs` will give you information if you have any errors in your new recipe file.
    ```
    python3 -m mkdocs serve  
    ```
    
    (If this doesn't work try `mkdocs serve` on its own)

- Point a web browser to the local site at http://localhost:8000 and navigate to your new recipe.

#### Staging on GitHub

If you are a Confluent employee, you can stage the site using the `mkdocs` GitHub integration. From the `master` branch (in the desired state):
- Run the provided script, `./release.sh`
- After a few minutes, the updated site will be available at https://confluentinc.github.io/ksqldb-recipes/

