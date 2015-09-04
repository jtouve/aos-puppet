node "my_aos_switch" {

  aos_a_vlan {
    "222":
      description => "puppet test vlan 222"
  }
  aos_a_vlan {
    "223":
      description => "puppet test vlan 223"
  }

  aos_b_interface {
    "1/1/1":
      vlan_tags => "222,223"
  }

  aos_b_interface {
    "1/1/2":
      vlan_tags => "222,223"
  }
}
