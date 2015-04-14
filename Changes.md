0.8.9
-----------

- We moved Web UI to materializecss.com CSS framework
- We moved from CDN to local assets for Web UI
- We show current state of a job in Web UI (thanks to @michaelachrisco) https://github.com/plashchynski/crono/issues/16
- We won't write a pidfile unless daemonized (thanks to @thomasfedb) https://github.com/plashchynski/crono/pull/13
- Fixed `rake crono:clean` task error
- Fixed issue when jobs scheduled at same time exclude each other https://github.com/plashchynski/crono/issues/19
- Fixed issue with a daemon crash due to `time interval must be positive` error


0.8.0
-----------

- Added `on` (day of week) option to cronotab.rb semantic
- Added job health check and job health indicator to the Web UI


0.7.0
-----------

- Added simple Web UI


0.6.1
-----------

- Persist job state to your database.


0.5.2
-----------

- Fix: Scheduled time now related to the last performing time.


0.5.1
-----------

- Added -e/--environment ENV option to set the daemon rails environment.


0.5.0
-----------

- Initial release!
