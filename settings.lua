data:extend({
  {
    type = "int-setting",
    name = "robotarmy-qrf-distance",
    setting_type = "runtime-global",
    default_value = 500,
    minimum_value = 0,
    maximum_value = 500,
    order = "a[qrf]"
  },
  {
    type = "bool-setting",
    name = "robotarmy-qrf-alert-enabled",
    setting_type = "runtime-global",
    default_value = true,
    order = "b[qrf-alert]"
  },
  {
    type = "bool-setting",
    name = "robotarmy-squad-death-messages",
    setting_type = "runtime-global",
    default_value = true,
    order = "c[squad-death]"
  },
  {
    type = "bool-setting",
    name = "robotarmy-qrf-respect-squad-size",
    setting_type = "runtime-global",
    default_value = false,
    order = "d[qrf-size]"
  }
})
