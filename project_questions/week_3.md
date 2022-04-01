# Week 3 Project

## Part 1 - Create new models to answer the first two questions

### What is our overall conversion rate?

In Week 2 I actually created a model that will allow me to answer this: `int_sessions_agg` provides session-level data. 
Using the below query, we can see that our overall conversion rate is **62.46%**
```
with agg_sessions as (
select 
  count(session_id) as num_sessions, 
  count(case when num_checkouts > 0 then session_id else null end) as num_purchase_sessions 
from dbt_mike_c.int_sessions_agg
)
select num_purchase_sessions::float/num_sessions::float from agg_sessions
```

### What is our conversion rate by product?
To build this, we need a model that, for each product, gives us session and order information. To do that, I built two intermediate models - `int_product_session` and `int_order_session`. These two are combined in `agg_product_outcomes`, which gives us the information needed to analyze outcomes at the product level. Conversion rate for a product could be based on a bunch of things, such as price, inventory, size, or required maintenance. Price sensitive customers may balk at spending a lot for a plant, especially if they aren't confident they can take care of it. 

```
select 
  product_name, 
  product_orders, 
  product_sessions, 
  product_orders::float/product_sessions::float * 100 as product_conversion_rate,
from dbt_mike_c.agg_product_outcomes 
```
|Product Name|Product Sessions|Product Orders|Product Conversion Rate|
| ---------- | -------------- | ------------ | --------------------- |
|Pothos|21|61|34.42622950819672|
|Bamboo|36|67|53.73134328358209|
|Philodendron|30|62|48.38709677419355|
|Monstera|25|49|51.02040816326531|
|String of pearls|39|64|60.9375|
|ZZ Plant|34|63|53.96825396825397|
|Snake Plant|29|73|39.726027397260275|
|Orchid|34|75|45.33333333333333|
|Birds Nest Fern|33|78|42.30769230769231|
|Calathea Makoyana|27|53|50.943396226415096|
|Peace Lily|27|66|40.909090909090914|
|Bird of Paradise|27|60|45|
|Fiddle Leaf Fig|28|56|50|
|Ficus|29|68|42.64705882352941|
|Pilea Peperomioides|28|59|47.45762711864407|
|Angel Wings Begonia|24|61|39.34426229508197|
|Jade Plant|22|46|47.82608695652174|
|Arrow Head|35|63|55.55555555555556|
|Majesty Palm|33|67|49.25373134328358|
|Spider Plant|28|59|47.45762711864407|
|Money Tree|26|56|46.42857142857143|
|Cactus|30|55|54.54545454545454|
|Devil's Ivy|22|45|48.888888888888886|
|Alocasia Polly|21|51|41.17647058823529|
|Pink Anthurium|31|74|41.891891891891895|
|Dragon Tree|29|62|46.774193548387096|
|Aloe Vera|32|65|49.23076923076923|
|Rubber Plant|28|54|51.85185185185185|
|Ponytail Palm|28|70|40|
|Boston Fern|26|63|41.269841269841265|

## Part 2 - Create a macro to simplify part of a model(s).

For time purposes, I'm going to go with what's recommended and build a macro to aggregate event types per session. I'm using something like this in `int_product_session` but since product events don't always have event types it isn't all that useful. The macro will be applied in `fct_user_sessions`. I created `agg_session_events` as a macro to identify the unique event types and then calculate the frequency of each. 

## Part 3 - Add a post hook to your project to apply grants to the role “reporting”.

See diff in PR for `dbt_project.yml`

## Part 4 - Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project

 * `dbt_utils` was already installed and I am using the `group_by` in several models. 
 * I added `dbt_expectations` so I could apply the `expect_column_pair_values_A_to_be_greater_than_B` to my `agg_profile_outcomes` model, as we should expect that you cannot have a product added more often than it's viewed, and ordered more often than it's added. 

## Part 5 - Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.

See `20220326_lineage.png` in `assets` directory for updated DAG. 