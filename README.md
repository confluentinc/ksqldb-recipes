# Stream Processing Use Cases with ksqlDB

This repository contains the source for the collection of Stream Processing Use Cases with ksqlDB.

Landing page: https://developer.confluent.io/ksqldb-recipes/

Recipes: https://confluentinc.github.io/ksqldb-recipes/

Goals of the project:

- Provide short, concrete descriptions of how ksqlDB is used in the real world—including SQL code.
- Make it easy to replicate that code end-to-end, with a `1-click` experience to populate the code into the ksqlDB editor in Confluent Cloud Console.

### How to contribute

We welcome all contributions, thank you!

_Contributing an idea?_ Submit a [GitHub issue](https://github.com/confluentinc/ksqldb-recipes/issues).

_Contributing a full recipe to be published?_ 

1. Self-assign a recipe idea from the list in [GitHub issues](https://github.com/confluentinc/ksqldb-recipes/issues?q=is%3Aissue+is%3Aopen+label%3A%22new+recipe%22).
2. Create a new branch (based off `main`) for the new recipe
3. Create a new subfolder for the new recipe, e.g. `docs/<industry>/<new-recipe-name>`
4. The recipe should follow the structure of [existing recipes](https://github.com/confluentinc/ksqldb-recipes/tree/main/docs). Copy the contents of an existing recipe (e.g. [aviation](https://github.com/confluentinc/ksqldb-recipes/tree/main/docs/customer-360/aviation)) or the [template](template) directory as the basis for your new recipe.

- [index.md](template/index.md): explain the use case, why it matters, add a graphic if available
- [source.json](template/source.json): JSON configuration to create Confluent Cloud source connectors to pull from a real end system
- [source.sql](template/source.sql): SQL commands to create Confluent Cloud source connectors to pull from a real end system (this file is not referenced today in `index.md`, but getting ready for ksqlDB-connect integration)
- [manual.sql](template/manual.sql): SQL commands to insert mock data into Kafka topics, if a user does not have a real end system
- [process.sql](template/process.sql): this is the core code of the recipe, the SQL commands that correspond to the event stream processing
- [sink.json](template/sink.json): (optional) JSON configuration to create Confluent Cloud sink connectors to push results to a real end system
- [sink.sql](template/sink.sql): (optional) SQL commands to create Confluent Cloud sink connectors to push results to a real end system (this file is not referenced today in `index.md`, but getting ready for ksqlDB-connect integration)

5. Submit a [GitHub Pull Request](https://github.com/confluentinc/ksqldb-recipes/pulls) and tag [confluentinc/devx](https://github.com/orgs/confluentinc/teams/devx) for review.

### Build locally

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

### Publishing

If you are a Confluent employee, you can publish using the `mkdocs` GitHub integration. From the `main` branch (in the desired state):

- Run the provided script, `./release.sh`
- After a few minutes, the updated site will be available at https://confluentinc.github.io/ksqldb-recipes/
