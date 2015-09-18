# Perlgres

The idea is to create a Rest API from a Postgres database. I am using this project to learn Perl.

### Endpoints
```shell
# List tables
GET /

# List table records
GET /:table

# List table columns
GET /:table/columns

# Add new record
POST /:table

# Show record
GET /:table/:id

# Remove record
DELETE /:table/:id
```
