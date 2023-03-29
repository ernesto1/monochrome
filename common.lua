-- :::::: common functions ::::::

--[[ prints the value provided by the conky variable after a applying a 'threshold' check to it.
If the threshhold is breached, the conky color variable is used to highlight the text, ex:

  ${lua_parse print_resource_usage ${cpu cpu0} 90 ${color3}}
  would yield: 87
               ${color3}96

use this method when you want to higlight high usage of a resource

arguments:
      expression      conky variable to parse, must yield a numeric value (no units)
      threshold       threshold to compare against
      colorVariable   conky color variable to print the expression under if the threshold is exceeded, ex. ${color4}
]]
function conky_print_resource_usage(expression, threshold, colorVariable)
  local value = tonumber(conky_parse(expression))
  local threshold = tonumber(threshold)
  local s = (value < threshold) and value or colorVariable .. value
  
  return s
end
