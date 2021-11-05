# ksqlDB Recipes

This repository contains a collection of ksqlDB Recipes.

#### How to contribute

If you'd like to contribute a recipe, please submit a Pull Request.
The content of that PR should follow the template established by existing recipes.
Browse through any recipe in https://github.com/confluentinc/ksqldb-recipes/tree/master/docs for more details.


#### Build locally

To view your new recipes locally, you can build a local version of the recipes site with `mkdocs`.

- Install `mkdocs` (https://www.mkdocs.org/)

    On macOS, you can use Homebrew:
    ```bash
    brew install mkdocs
    pip3 install mkdocs pymdown-extensions
    ```

- Build and serve a local version of the site. In this step, `mkdocs` will give you information if you have any errors in your new recipe file.
    ```
    python3 -m mkdocs serve  
    ```

- Point a web browser to the local site at http://localhost:8000 and navigate to your new recipe.

#### Staging on GitHub

If you are a Confluent employee, you can stage the site using the `mkdocs` GitHub integration. From the `master` branch (in the desired state):
- Run the provided script, `./release.sh`
- After a few minutes, the updated site will be available at https://confluentinc.github.io/ksqldb-recipes/

