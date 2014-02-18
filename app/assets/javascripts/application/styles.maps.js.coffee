window.Nembrot.map_styles = {

  # http://snazzymaps.com/style/5/greyscale
  'greyscale': [{"featureType":"all","stylers":[{"saturation":-100},{"gamma":0.5}]}]

  # http://snazzymaps.com/style/3/red-alert
  'red_alert' : [
                  {
                    featureType: "water"
                    elementType: "geometry"
                    stylers: [color: "#ffdfa6"]
                  }
                  {
                    featureType: "landscape"
                    elementType: "geometry"
                    stylers: [color: "#b52127"]
                  }
                  {
                    featureType: "poi"
                    elementType: "geometry"
                    stylers: [color: "#c5531b"]
                  }
                  {
                    featureType: "road.highway"
                    elementType: "geometry.fill"
                    stylers: [
                      {
                        color: "#74001b"
                      }
                      {
                        lightness: -10
                      }
                    ]
                  }
                  {
                    featureType: "road.highway"
                    elementType: "geometry.stroke"
                    stylers: [color: "#da3c3c"]
                  }
                  {
                    featureType: "road.arterial"
                    elementType: "geometry.fill"
                    stylers: [color: "#74001b"]
                  }
                  {
                    featureType: "road.arterial"
                    elementType: "geometry.stroke"
                    stylers: [color: "#da3c3c"]
                  }
                  {
                    featureType: "road.local"
                    elementType: "geometry.fill"
                    stylers: [color: "#990c19"]
                  }
                  {
                    elementType: "labels.text.fill"
                    stylers: [color: "#ffffff"]
                  }
                  {
                    elementType: "labels.text.stroke"
                    stylers: [
                      {
                        color: "#74001b"
                      }
                      {
                        lightness: -8
                      }
                    ]
                  }
                  {
                    featureType: "transit"
                    elementType: "geometry"
                    stylers: [
                      {
                        color: "#6a0d10"
                      }
                      {
                        visibility: "on"
                      }
                    ]
                  }
                  {
                    featureType: "administrative"
                    elementType: "geometry"
                    stylers: [
                      {
                        color: "#ffdfa6"
                      }
                      {
                        weight: 0.4
                      }
                    ]
                  }
                  {
                    featureType: "road.local"
                    elementType: "geometry.stroke"
                    stylers: [visibility: "off"]
                  }
                ]

}
