const https = require('https');
const fs = require('fs');

const options = {
  hostname: 'miljodataportalen.stockholm.se',
  path: '/api/buller-2022-vagtagflygleq24h',
  method: 'GET',
  headers: {
    'Accept': 'application/json'
  }
};

const request = https.request(options, (response) => {
  let data = '';

  response.on('data', (chunk) => {
    data += chunk;
  });

  response.on('end', () => {
    const decodedResponse = JSON.parse(data);
    const polygons = decodedResponse.table.records.map(record => record.geom);

    const outputFile = 'polygon_buller_api.json';

    // Write polygons to JSON file
    const stream = fs.createWriteStream(outputFile);
    stream.once('open', () => {
      const polygonFeatures = polygons.map((polygon, index) => {
        let coordinates = polygon.substring(9, polygon.length - 2); // Remove "POLYGON((" and "))" from the string
        let coordinatePairs = coordinates.split(',');

        // Format the coordinates for Google Maps
        let formattedCoordinates = coordinatePairs.map((coordinatePair) => {
          let coordinates = coordinatePair.trim().split(' ');
          let [lat, lng] = SWEREF99_18_00toWGS84(coordinates[1], coordinates[0]);
          return [lat, lng]; // GeoJSON expects [longitude, latitude] order
        });

        return {
          type: 'Feature',
          geometry: {
            type: 'Polygon',
            coordinates: [formattedCoordinates]
          },
          properties: {
            id: index + 1
          }
        };
      });

      const geoJsonData = {
        type: 'FeatureCollection',
        features: polygonFeatures
      };

      stream.write(JSON.stringify(geoJsonData));
      stream.end();
      console.log(`Polygons written to ${outputFile}`);
    });
  });
});

request.on('error', (error) => {
  console.error(error);
});

request.end();


//Due to the lack of library for the conversion I found a github repository that gave a solution to the conversion
// https://github.com/arnoldandreasson/latlong_mellifica_se
// Conversion from grid coordinates to geodetic coordinates.
axis = 6378137.0; // GRS 80.
flattening = 1.0 / 298.257222101; // GRS 80.
central_meridian = null;
lat_of_origin = 0.0;
scale = 1.0;
false_northing = 0.0;
false_easting = 150000.0;
central_meridian = 18.00;

function SWEREF99_18_00toWGS84(x, y) {
    var lat_lon = new Array(2);
    if (central_meridian == null) {
        return lat_lon;
    }
    // Prepare ellipsoid-based stuff.
    var e2 = flattening * (2.0 - flattening);
    var n = flattening / (2.0 - flattening);
    var a_roof = axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0);
    var delta1 = n / 2.0 - 2.0 * n * n / 3.0 + 37.0 * n * n * n / 96.0 - n * n * n * n / 360.0;
    var delta2 = n * n / 48.0 + n * n * n / 15.0 - 437.0 * n * n * n * n / 1440.0;
    var delta3 = 17.0 * n * n * n / 480.0 - 37 * n * n * n * n / 840.0;
    var delta4 = 4397.0 * n * n * n * n / 161280.0;

    var Astar = e2 + e2 * e2 + e2 * e2 * e2 + e2 * e2 * e2 * e2;
    var Bstar = -(7.0 * e2 * e2 + 17.0 * e2 * e2 * e2 + 30.0 * e2 * e2 * e2 * e2) / 6.0;
    var Cstar = (224.0 * e2 * e2 * e2 + 889.0 * e2 * e2 * e2 * e2) / 120.0;
    var Dstar = -(4279.0 * e2 * e2 * e2 * e2) / 1260.0;

    // Convert.
    var deg_to_rad = Math.PI / 180;
    var lambda_zero = central_meridian * deg_to_rad;
    var xi = (x - false_northing) / (scale * a_roof);
    var eta = (y - false_easting) / (scale * a_roof);
    var xi_prim = xi -
        delta1 * Math.sin(2.0 * xi) * math_cosh(2.0 * eta) -
        delta2 * Math.sin(4.0 * xi) * math_cosh(4.0 * eta) -
        delta3 * Math.sin(6.0 * xi) * math_cosh(6.0 * eta) -
        delta4 * Math.sin(8.0 * xi) * math_cosh(8.0 * eta);
    var eta_prim = eta -
        delta1 * Math.cos(2.0 * xi) * math_sinh(2.0 * eta) -
        delta2 * Math.cos(4.0 * xi) * math_sinh(4.0 * eta) -
        delta3 * Math.cos(6.0 * xi) * math_sinh(6.0 * eta) -
        delta4 * Math.cos(8.0 * xi) * math_sinh(8.0 * eta);
    var phi_star = Math.asin(Math.sin(xi_prim) / math_cosh(eta_prim));
    var delta_lambda = Math.atan(math_sinh(eta_prim) / Math.cos(xi_prim));
    var lon_radian = lambda_zero + delta_lambda;
    var lat_radian = phi_star + Math.sin(phi_star) * Math.cos(phi_star) *
        (Astar +
            Bstar * Math.pow(Math.sin(phi_star), 2) +
            Cstar * Math.pow(Math.sin(phi_star), 4) +
            Dstar * Math.pow(Math.sin(phi_star), 6));
    lat_lon[0] = lat_radian * 180.0 / Math.PI;
    lat_lon[1] = lon_radian * 180.0 / Math.PI;
    return lat_lon;
}

// Missing functions in the Math library.
function math_sinh(value) {
    return 0.5 * (Math.exp(value) - Math.exp(-value));
}
function math_cosh(value) {
    return 0.5 * (Math.exp(value) + Math.exp(-value));
}
function math_atanh(value) {
    return 0.5 * Math.log((1.0 + value) / (1.0 - value));
}

