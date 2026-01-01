# Insurance Data engineering project
This is a hand-on demo project creating a end-to-end data engineering pipeline for a Insurance provider customer data set.
The data set is synthetically generated using Faker python module and loaded onto a django web application database. The link to the code base - [Link](https://github.com/neeraj-nb/Insurance-dataengineering/tree/main/insurance_project)

The Transformations and done using DBT core. The link to the DBT project [Link](https://github.com/neeraj-nb/Insurance-dataengineering/tree/main/data-engineering/dbt/insurance)

The demo used Redshift as Warehouse and compute. To use any other warehouse add the respective dbt plugin to the requirement file in dbt project and setup the credentials in profiles.yml.