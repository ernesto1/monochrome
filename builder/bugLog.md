# Conky Bug Log
List of issues found while bulding my conky configs in Fedora.  
Due to bugs in the latest conky version available on the distro, I am stuck with coding against the somewhat stable versions that are `conky 1.11.5_pre` and `lua 5.4.4`.

The problems always comes down to conky variables that don't play well together, making me have to physically separate things in order to get it to work >.<

### `top mem` variables mess up `memgraph` and `memperc`
The graph jitters at random intervals.  It looks bad.  It is as if it calculated memory to be 0 or negative for certain intervals.

Impact

- **compact** | placing memory variables into two separate conkys
- **widgets** | placing memory variables into two separate conkys

### `top cpu` variables don't mix with `lua` variables
The top 1 cpu process is incorrect.  It is as if top 2 became top 1.  

Impact

- **compact** | separating temperatures from the sidebar conky 
- **all** | separating transmission + packages from system conky.  
CPU usage was crazy high for the system conky as well when everything was together.  It was running at 30% for a single core.  Compare that to any other conky at 1-2%.  
Just drawing a vertical table with the lua draw image function alone (8 images) would spike the conky by 3-4%.  The `compact transmission` conky had multiple uses of this function and it would run at 1%.

### `${if_existing processId}` does not mix with `lua` variables
The cost of the variable increases the conky cpu usage from 1% to 15%

### `execpi` not honoring intervals
The command invoked by this variable was being executed on each conky iteration instead of each interval, neglecting the whole point.  According to the conky project bug tracker, this seems to have been fixed on a newer version of conky.

## Introduce delays when launching conkys
Having to separate elements of the same conky (ex. memory conky) due to the variable conflicts required me to introduce special logic to the `launch.bash` script in order to introduce delays to certain conkys when launching them.  
This would guarantee the conkys would load on top of each other properly.
