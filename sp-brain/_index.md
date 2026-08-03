# sp-brain index

Catalog of SharePoint sites and lists registered for sync
(`sync/sp-sync-spec.md`). This registration is what keeps
`service_claude`'s read scope deliberate rather than tenant-wide.

| Topic | SharePoint site | List/library | Last delta token | Last webhook renewal |
|---|---|---|---|---|
| example-topic | _(placeholder, not yet registered)_ | | | |

To register a site: add a row with the site and list IDs via PR, reviewed
like any other change. `service_claude` creates the initial Graph
subscription on merge.

The last two columns are runtime state that changes every sync and doesn't
belong in a reviewed file. See `DESIGN-REVIEW.md` D8.
