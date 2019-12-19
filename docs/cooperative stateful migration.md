# Cooperative stateful migration #
In [this page](stateful%20migration.md) we have broken down the problem of migrating service state within containerized applications. Those methods have to be contextualized in real-case scenarios of a container being migrated to a different node in a stateful way.

Before [putting all pieces together](#traditional-stateful-migration), we detail the possible cases of stateful migration:
- **[User-service stateful migration](#user-service-stateful-migration)** (request)
- **[User-service session migration](#user-service-session-migration)** (session, request)
- **[Stateful container migration](#stateful-container-migration)** (application, session, request)

Finally, we try to perform stateful migration in a [cooperative way](#cooperative-stateful-migration-cached-user-blocks).

## User-service stateful migration ##

## User-service session migration ##

## Stateful container migration ##

## Traditional stateful migration ##

## Cooperative stateful migration: cached user blocks ##
