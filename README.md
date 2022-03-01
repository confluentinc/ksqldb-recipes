# Stream Processing Use Cases with ksqlDB [DEPRECATED]

This repository contains the source for the collection of Stream Processing Use Cases with ksqlDB.

https://developer.confluent.io/tutorials/use-cases.html

Goals of the project:

- Provide short, concrete descriptions of how ksqlDB is used in the real world—including SQL code.
- Make it easy to replicate that code end-to-end, with a `1-click` experience to populate the code into the ksqlDB editor in Confluent Cloud Console.

### How to contribute

We welcome all contributions, thank you!

_Contributing an idea?_ Submit a [GitHub issue](https://github.com/confluentinc/ksqldb-recipes/issues).

_Contributing a full recipe to be published?_ 

1. Self-assign a recipe idea from the list in [GitHub issues](https://github.com/confluentinc/ksqldb-recipes/issues?q=is%3Aissue+is%3Aopen+label%3A%22new+recipe%22).
2. Create a new branch (based off `main`) for the new recipe
3. Create a new subfolder for the new recipe, e.g. `docs/<industry>/<new-recipe-name>`. Note: `<new-recipe-name>` is the slug in Confluent Cloud. Use hyphens, not underscores.
4. The recipe should follow the structure of [existing recipes](https://github.com/confluentinc/ksqldb-recipes/tree/main/docs). Copy the contents of an existing recipe (e.g. [aviation](https://github.com/confluentinc/ksqldb-recipes/tree/main/docs/customer-360/aviation)) or the [template](template) directory as the basis for your new recipe.

- [index.md](template/index.md): explain the use case, why it matters, add a graphic if available
- [source.json](template/source.json): JSON configuration to create Confluent Cloud source connectors to pull from a real end system
- [source.sql](template/source.sql): SQL-equivalent of `source.json` (this file is not referenced today in `index.md`, but getting ready for ksqlDB-connect integration)
- [manual.sql](template/manual.sql): SQL commands to insert mock data into Kafka topics, if a user does not have a real end system
- [process.sql](template/process.sql): this is the core code of the recipe, the SQL commands that correspond to the event stream processing
- [sink.json](template/sink.json): (optional) JSON configuration to create Confluent Cloud sink connectors to push results to a real end system
- [sink.sql](template/sink.sql): (optional unless `sink.json` is provided) SQL-equivalent of `sink.json` (this file is not referenced today in `index.md`, but getting ready for ksqlDB-connect integration)

5. Validation: you do not need to create a real end system, real data, and a real source connector, but you should ensure the connector configuration is syntactically correct. Do validate that the core ksqlDB stream processing code works with the manual `INSERT INTO` statements, and that the last ksqlDB query returns the expected records.

6. Submit a [GitHub Pull Request](https://github.com/confluentinc/ksqldb-recipes/pulls). Ensure the new recipe adheres to the [checklist](https://github.com/confluentinc/ksqldb-recipes/blob/main/.github/pull_request_template.md) and then tag [confluentinc/devx](https://github.com/orgs/confluentinc/teams/devx) for review.

### Handling connectors

A recipe is more compelling if it uses Confluent Cloud fully-managed connectors, especially when the ksqlDB-connect integration is ready.
But what if the recipe you want to write does not have a connector available in Confluent Cloud?
Some options for your to consider, in order of preference:

1. Stick with the original recipe idea, but use another connector in Confluent Cloud, that still fits the use case
2. Pick a different recipe, maybe in the same industry, that uses a connector available in Confluent Cloud. This maximizes the impact of your recipe contribution
3. Stick with your original recipe idea, and use a self-managed connector that runs locally. Follow precedent steps in [this recipe](https://confluentinc.github.io/ksqldb-recipes/cybersecurity/SSH-attack/#read-the-data-in)

### Build recipes docs locally

To view your new recipes locally, you can build a local version of the recipes site with `mkdocs`.

- Install `mkdocs` (https://www.mkdocs.org/)

    On macOS, you can use Homebrew:
    ```bash
    brew install mkdocs
    pip3 install mkdocs pymdown-extensions
    pip3 install mkdocs-material
    pip3 install mkdocs-exclude
    pip3 install mkdocs-redirects
    ```

- Build and serve a local version of the site. In this step, `mkdocs` will give you information if you have any errors in your new recipe file.
    ```
    python3 -m mkdocs serve  
    ```
    
    (If this doesn't work try `mkdocs serve` on its own)

- Point a web browser to the local site at http://localhost:8000 and navigate to your new recipe.

### Publishing recipes to live site

If you are a Confluent employee, you can publish using the `mkdocs` GitHub integration. From the `main` branch (in the desired state):

- Run the provided script, `./release.sh`
- After a few minutes, the updated site will be available at https://confluentinc.github.io/ksqldb-recipes/
