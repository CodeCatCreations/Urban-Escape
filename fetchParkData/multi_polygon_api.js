const https = require('https');
const fs = require('fs');
const parseString = require('xml2js').parseString;

const options = {
  headers: {
    'Accept': 'application/xml'
  }
};

https.get('https://miljodataportalen.stockholm.se/api/buller-2022-vagtagflygleq24h/', options, (response) => {
  let data = '';

  response.on('data', (chunk) => {
    data += chunk;
  });

  response.on('end', () => {
    parseString(data, (err, result) => {
      if (err) throw err;

      const geoms = result.miljodata.table[0].record.map((record) => record.geom[0]);

      const polygons = [];
      const coordinates = [];

      let currentId = 1;
      for (const geom of geoms) {
        const openingParensIndex = geom.indexOf('((');
        const closingParensIndex = geom.lastIndexOf('))');
        const subGeom = geom.substring(openingParensIndex + 2, closingParensIndex);
        if (!geom.includes("EMPTY") && subGeom.indexOf('((') !== -1 || subGeom.indexOf(')') !== -1) {
          const coordsSets = subGeom.split('),('); // split subGeom into an array of strings where each string represents a set of coordinates
          polygons.push(`INSERT INTO multipolygons (id, name) VALUES (${currentId}, 'Polygon ${currentId}');`);
          for (let i = 0; i < coordsSets.length; i++) {
            const coords = coordsSets[i].split(',').map(coord => coord.trim().split(' '));
            for (let j = 0; j < coords.length; j++) {
              const coordinatesData = coords[j];
              let [lat, lng] = SWEREF99_18_00toWGS84(coordinatesData[1], coordinatesData[0]); // Convert coordinates to WGS84
              coordinates.push(`INSERT INTO multicoordinates (polygon_id, latitude, longitude) VALUES (${currentId}, ${lat}, ${lng});`);
            }
          }
          currentId++;
        }
      }
      
      // Write the polygons and coordinates to files
      fs.writeFile('multipolygons.sql', polygons.join('\n'), (err) => {
        if (err) throw err;
        console.log('Polygons written to polygons.sql');
      });

      fs.writeFile('multicoordinates.sql', coordinates.join('\n'), (err) => {
        if (err) throw err;
        console.log('Coordinates written to coordinates.sql');
      });
    });
  });
}).on('error', (err) => {
  console.log('Error: ' + err.message);
});














































/*
const https = require('https');
const fs = require('fs');
const parseString = require('xml2js').parseString;

const options = {
  headers: {
    'Accept': 'application/xml'
  }
};

https.get('https://miljodataportalen.stockholm.se/api/buller-2022-vagtagflygleq24h?$limit=15&$offset=0', options, (response) => {
  let data = '';

  response.on('data', (chunk) => {
    data += chunk;
  });

  response.on('end', () => {
    parseString(data, (err, result) => {
      if (err) throw err;

      let multipolygonId = 1;
      let polygonId = 1;
      let polygonStatements = '';
      let multipolygonStatements = 'INSERT INTO multipolygon(multipolygon_id, polygon_ids) VALUES\n';
    
      const geoms = result.miljodata.table[0].record.map((record) => record.geom[0]);
    
      for (const geom of geoms) {
        const openingParensIndex = geom.indexOf('((');
        const closingParensIndex = geom.lastIndexOf('))');
        const subGeom = geom.substring(openingParensIndex + 2, closingParensIndex);
        if (subGeom.indexOf('((') !== -1 || subGeom.indexOf(')') !== -1) {
          const polygons = subGeom.split('),(');
          const polygonIds = [];
          for (let i = 0; i < polygons.length; i++) {
            const coords = polygons[i].split(',').map(coord => coord.trim());
            for (let j = 0; j < coords.length; j++) {
              const [lat, lon] = SWEREF99_18_00toWGS84(coords[j].split(' ')[1], coords[j].split(' ')[0]); // Convert coordinates to WGS84
              polygonStatements += `INSERT INTO polygonToMultiPolygon(multipolygon_id, polygon_id, latitude, longitude) VALUES (${multipolygonId}, ${polygonId}, ${lat}, ${lon});\n`;
            }
            polygonIds.push(polygonId);
            polygonId++;
          }
          multipolygonStatements += `(${multipolygonId}, '{${polygonIds.join(',')}}'),\n`;
          multipolygonId++;
          polygonId = 1;
        }
      }

      // Remove the last comma and new line character from multipolygonStatements
      multipolygonStatements = multipolygonStatements.substring(0, multipolygonStatements.length - 2);
      
      fs.writeFile('polygonsToMultipolygons.sql', polygonStatements, (err) => {
        if (err) throw err;
        console.log('SQL statements written to output.sql');
      });
      
      fs.writeFile('multipolygonsID.sql', multipolygonStatements, (err) => {
        if (err) throw err;
        console.log('SQL statements written to multipolygon.sql');
      });
    });
  });
}).on('error', (err) => {
  console.log('Error: ' + err.message);
});
*/












/*
const https = require('https');
const fs = require('fs');
const parseString = require('xml2js').parseString;

const options = {
  headers: {
    'Accept': 'application/xml'
  }
};

https.get('https://miljodataportalen.stockholm.se/api/buller-2022-vagtagflygleq24h?$limit=15&$offset=0', options, (response) => {
  let data = '';

  response.on('data', (chunk) => {
    data += chunk;
  });

  response.on('end', () => {
    parseString(data, (err, result) => {
      if (err) throw err;

      const geoms = result.miljodata.table[0].record.map((record) => record.geom[0]);

      const stream = fs.createWriteStream('output.txt');

      let polygonNum = 1;

      for (const geom of geoms) {
        const openingParensIndex = geom.indexOf('((');
        const closingParensIndex = geom.lastIndexOf('))');
        const subGeom = geom.substring(openingParensIndex + 2, closingParensIndex);
        if (subGeom.indexOf('((') !== -1 || subGeom.indexOf(')') !== -1) {
          const polygons = subGeom.split('),(');
          for (let i = 0; i < polygons.length; i++) {
            stream.write(`Polygon ${polygonNum}`);
            polygonNum++;
            const polygon = polygons[i];
            const coordinates = polygon.split(',').map(coord => `(${coord})`).join(', ');
            stream.write(` ${coordinates}`);
            if (i !== polygons.length - 1) {
              stream.write('\n');
            }
          }
          stream.write('\n\n');
        }
      }

      stream.end();
    });
  });
}).on('error', (err) => {
  console.log('Error: ' + err.message);
});
*/



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










