* bin/build will create the artifacts. You'll need the ansible vars and a bit more info.
  Run it with `--help` for more info.
* bin/push will push to faux-infrastructure, faux-deploy, and faux-dev.
  You'll just need to specify
  the dir. Again, see `--help`.
* bin/protect will protect the faux-dev branch. You'll need to resupply the instance name to
  `--branch` as well as supply a team name to `--team`. For more on what the team should be,
  see below.

### Teams

Fauxpaas's authorization design heavily encourages the use of project leads on a per
named instance basis. On Github, we protect the faux-dev branch for each instance
by limiting privileges to the owning team (currently, only the team can push; later
we would like to limit visibility to only the team).

While we could mint a team for
every instance automtically, that diverges from the use case. We would end up
with a scenario with a "Fulcrum Production" team, a "Fulcrum Dev" team, etc etc etc.
Instead, we expect project managers to create a Github team out of band, e.g. "Fulcrum",
and given the name prefaux will grant that team privileges on the faux-dev branch.
