# Week 4 Project

## Part 1 - dbt Snapshot

### Create a snapshot model using the `orders` source in the `/snapshots/` directory of our dbt project
See `snapshots/order_snapshot.sql` for snapshot model and `dbt_project.yml` for updated config
### Run the snapshot model to create it in our database
`dbt snapshot -s order_snapshot`
### Run `delivery-update.sh` to update the delivery status of some (3) orders. The order Ids are ('914b8929-e04a-40f8-86ee-357f2be3a2a2', '05202733-0e17-4726-97c2-0520c024ab85','939767ac-357a-4bec-91f8-a7b25edd46c9')
```
cd ..
./delivery-update.sh
```
### Run `dbt snapshot` agin and see howt he data has changed
`dbt snapshot -s order_snapshot`
Checked the db using the below query. The order_ids that were updated now show that the intial records are valied from when `status` was `preparing` to when it became `shipped`. The records where `status = shipped` are the current "valid" records.

```
select * from dbt_mike_c.order_snapshot WHERE order_id IN ('914b8929-e04a-40f8-86ee-357f2be3a2a2', '05202733-0e17-4726-97c2-0520c024ab85','939767ac-357a-4bec-91f8-a7b25edd46c9')
```

## Part 2 - Modeling challenge

### How are our users moving through the product funnel? Which steps in the funnel have largest drop off points?

1. Please create any additional dbt models needed to help answer these questions from our product team, and put your answers in a README in your repo.

My `int_sessions_agg` model and the `fct_user_sessions` model that is built from it includes the information I need to answer these questions. I decided to build an agg model (`agg_product_funnel`) that contains some metrics that could be used in a dashboard. This provides funnel metrics by day (total sessions, cart sessions, add to cart sessions, add to cart rate, and conversion rate) and to date (cumulative sessions, cumulative cart sessions, cumulative add to cart sessions, total add to cart rate, total conversion rate). This would faciliate visualizations that show change over time and facilitate questions for deeper analysis. One thing I didn't do here that would be fun is adding a metric that calculates the change in rates so we may trigger alerts off of them. In practice I wouldn't do necessarily do this by day but we didn't have much data. 

Also, building off the logic used in the tests I build last week, I am going to simplify the logic such that:
 * total sessions are any session with a page view (can't add to cart if the page wasn't viewed, can't checkout without adding to cart)
 * cart sessions are any session with an add to cart event (can't checkout without adding to cart)
 * checkout sessions are any session with a checkout (requires first two)

To date, we are seeing 80.80% add to cart rate and 62.46% conversion rate. So we are losing the most from page view to cart (19.20%), but not much more than from cart to checkout (17.66%). 

2. Use an exposure on your product analytics model to represent that this is being used in downstream BI tools. Please reference the course content if you have questions.

See `exposure.yml` and `exposure_*` images in `/assets` folder.  

## Reflection Questions

### Part 3A. dbt next steps for you

_Reflecting on your learning in this class..._

 * _if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?_
 * _if your organization is using dbt, what are 1-2 things you might do differently / recommend to your organization based on learning from this course?_
 * _if you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step?_

So I pitched (and go approval for) dbt cloud last year and just got over the line with procurement and legal last week so the timing is pretty awessome. I can't share the deck, but I pitched it by mapping dbt's strengths (modularity + repeatability of SWE best practices, transparency via documentation, the fact SQL is more commonly known) to existing challenges and our long-term data strategy (integration with Headless BI model) The biggest things I learned that I will try to apply in our integration are snapshots - these are going to make our lives so much better as it will help us avoid "popcorn data". Also, we have some pretty heavy audit requirements, so I'm looking forward to digging into artifacts to see if we can can leverage the data there to meet audit's needs.

### Part 3B. Setting up for production/scheduled dbt run of your project

_And finally, before you fly free into the dbt night, we will take a step back and reflect: after learning about the various options for dbt deployment and seeing your final dbt project, how would you go about setting up a production/scheduled dbt run of your project in an ideal state? You don’t have to actually set anything up - just jot down what you would do and why and post in a README file._

So this is actually an interesting question because we are going to have dbt deployed to several instances (APAC, EU, NA) where the types of sources will be the same (e.g. underwriting platform) but how data comes in and what data is provided will be vastly different. We need to figure out a way to leverage certain macros to keep definitions consistent but also be able to deploy those to what are effectively different projects. To keep the conversation simpler I'll talk about the first project we will be using dbt on, which is (unfortunately) named the [Phoenix project](https://www.amazon.com/Phoenix-Project-DevOps-Helping-Business/dp/1942788290/ref=tmm_pap_swatch_0?_encoding=UTF8&qid=1648780604&sr=8-1). 

Our EL pipelines are all built in AWS Glue. This one will be ingesting data from Postgres and loading it into Redshfit every hour (orchestrated via AWS Glue workflows). So when I initially thought about this, I kinda stressed about how we would time it properly. However, based on what I've learned in the class it looks like we could add a post-optimization (that's what we call the process which writes to Redshift) job that makes an API call to dbt Cloud to kick off the dbt run. We may not want to run everything hourly (e.g. snapshots where we only care about daily changes), so would want to make sure we are thoughtful about what we include there and what we can get away with running on a CRON schedule via dbt Cloud's orchestration. I would expect an hourly run to loosely follow a flow of snapshot-run-test-document with the metadata updates integrated throughout.  As mentioned above, we have some strict audit requirements, so I would to explore `catalog.json` to see if ther is data there we can leveage to show that data is loaded and updated properly. We're doing a lot of alerting through Slack via DataDog so pushing alerts there would make sense for consistency. 

