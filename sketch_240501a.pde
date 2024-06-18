import java.util.Collections;
boolean showTop7 = false;
boolean showLowest7 = false;
PImage mapImage;
Table locationTable;
int rowCount;
float zoom = 1.0;
float offsetX = 0;
float offsetY = 0;

String title = "2023"; // Variable to store the title
int currentColumn = 3; // Initially, plot the current population from column 4 (2023)

void setup() {
  size(800, 600);
  mapImage = loadImage("map.png");
  mapImage.resize(width, height);
  locationTable = loadTable("Locations.tsv");
  
  if (locationTable == null || locationTable.getRowCount() == 0) {
    println("Error: Unable to load the data file or no data available.");
    exit(); // Terminate the sketch if the file cannot be loaded or no data is available
  } else {
    println("Data file loaded successfully.");
    rowCount = locationTable.getRowCount();
  }
}


void draw() {
  background(255);
  
  pushMatrix(); // Save the current transformation matrix
  translate(offsetX, offsetY); // Apply panning (Changing the orgin)
  scale(zoom); // Apply zoom
  
  image(mapImage, 0, 0, width, height); // Draw map image as background
  
  smooth() ;
  
  // Calculate maximum population dynamically
  int maxPop = maxPopulation();
  

  ArrayList<Integer> populationsToShow;
  if (showTop7) {
    populationsToShow = getTopPopulations(7);
  } else if (showLowest7) {
    populationsToShow = getLowestPopulations(7);
  } else {
    populationsToShow = getAllPopulations();
  }
  
  for (int row = 0; row < rowCount; row++) {
    float x = locationTable.getFloat(row, 1);
    float y = locationTable.getFloat(row, 2);
    
    // Check if population data for the current column is valid
    if (locationTable.getString(row, currentColumn) != null && !locationTable.getString(row, currentColumn).isEmpty()) {
      int population = locationTable.getInt(row, currentColumn); // Get population data
      
      // Plot only if the population is in populationsToShow
      if (populationsToShow.contains(population)) {
        // Map x and y coordinates to fit within the screen space
        float plotX = map(x, 0, mapImage.width, 0, width);
        float plotY = map(y, 0, mapImage.height, height, 0);
        
        // Map population size to circle size
        float minCircleSize = 5;
        float circleSize = max(minCircleSize, map(population, 0, maxPop, minCircleSize, 25)); // Adjust circle size mapping
        
        // Determine color based on column
        float hue;
        if (currentColumn == 3) {
          hue = map(population, 0, maxPop, 260, 290); // Gradient from purple to blue for 2023 (Purple Lake)
        } else if (currentColumn == 4) {
          hue = map(population, 0, maxPop, 180, 240); // Gradient of Ocean Blue for 2012
        } else if (currentColumn == 5) {
          hue = map(population, 0, maxPop, 156, 180); // Gradient from green to cyan for 2006 (Quepal)
        } else {
          hue = 0; // Default hue value
        }
        
        float saturation = 255; // Max saturation    to provide eye-catching visuals
        float brightness = 255; // Max brightness
        fill(hue, saturation, brightness); // Set color for the the ellipse (After)
        
        ellipse(plotX, plotY, circleSize, circleSize);
      }
    }
  }
  
  popMatrix(); // Restore the previous transformation matrix
  
  drawLegend(maxPop);
  
  // Draw the title
  textAlign(LEFT, TOP);
  textSize(40);
  fill(0);
  text(title, 670, 400); // Adjust the position as needed
}

void drawLegend(int maxPop) {
  // Define legend properties
  float legendX = width - 250;
  float legendY = height - 200;
  float legendWidth = 200;
  float legendHeight = 150;
  float keyLegendHeight = 60;
  float labelSpacing = legendHeight / 10; // Calculate vertical spacing between legend labels
  
  // Draw legend border and background
  stroke(0);
  fill(255);
  rect(legendX, legendY, legendWidth, legendHeight);
  
  // Draw legend gradient
  for (int i = 0; i <= legendHeight; i++) {
    float hue;
    if (currentColumn == 3) {
      hue = map(i, 0, legendHeight, 260, 290); // Gradient from purple to blue for 2023 (Purple Lake)
    } else if (currentColumn == 4) {
      hue = map(i, 0, legendHeight, 180, 240); // Gradient of Ocean Blue for 2012
    } else if (currentColumn == 5) {
      hue = map(i, 0, legendHeight, 156, 180); // Gradient from green to cyan for 2006 (Quepal)
    } else {
      hue = 0; // Default hue value
    }
    colorMode(HSB, 360, 100, 100); // change the colors from RGB
    fill(hue, 80, 90); // Adjust saturation and brightness for better visualization
    noStroke(); // remove border for the rect
    rect(legendX + 5, legendY + i, 10, 1);
  }
  
  // Draw legend labels
  textAlign(LEFT, TOP);
  textSize(10);
  fill(0); // Set text color to black
  
  // Define ranges dynamically based on maxPop
  int numRanges = 10;
  int step = maxPop / numRanges;
  String[] ranges = new String[numRanges];
  for (int i = 0; i < numRanges; i++) {
    float start = i * step;
    float end = (i + 1) * step;
    ranges[i] = formatPopulation(start) + "-" + formatPopulation(end);
  }
  
  for (int i = 0; i < numRanges; i++) {
    float labelY = legendY + i * labelSpacing;
    
    // Determine color based on column
    float hue;
    if (currentColumn == 3) {
      hue = map((i + 1) * step, 0, maxPop, 260, 290); // Gradient from purple to blue for 2023 (Purple Lake)
    } else if (currentColumn == 4) {
      hue = map((i + 1) * step, 0, maxPop, 180, 240); // Gradient of Ocean Blue for 2012
    } else if (currentColumn == 5) {
      hue = map((i + 1) * step, 0, maxPop, 156, 180); // Gradient from green to cyan for 2006 (Quepal)
    } else {
      hue = 0; // Default hue value
    }
    
    // Draw colored rectangle for each range
    fill(hue, 80, 90); // Adjust saturation and brightness for better visualization
    noStroke();
    rect(legendX + 20, labelY - 5, 10, 10);
    
    // Draw range label
    fill(0);
    text(ranges[i], legendX + 40, labelY);
  }
  
  // Draw legend title
  fill(0);
  textAlign(LEFT, CENTER);
  textSize(16);
  text("Population Legend", legendX + 100, legendY + 50);
  
  // Calculate position for key legend
  float keyLegendX = legendX + 20 + textWidth(ranges[numRanges - 1]) + 10;
  float keyLegendY = legendY + legendHeight - keyLegendHeight;
  
  // Draw legend for key pressing
  fill(0);
  textSize(12);
  textAlign(LEFT, TOP);
  text("        Press:", keyLegendX, keyLegendY);
  text("4 for 2023", keyLegendX + 20, keyLegendY + 15);
  text("5 for 2012", keyLegendX + 20, keyLegendY + 30);
  text("6 for 2006", keyLegendX + 20, keyLegendY + 45);
}

String formatPopulation(float population) {
  if (population >= 1000000) {
    return nf(population / 1000000, 0, 2) + "m";
  } else if (population >= 1000) {
    return nf(population / 1000, 0, 2) + "k";
  } else {
    return nf(population, 0, 2);
  }
}
int maxPopulation() {
  int maxPop = 0;
  for (int row = 0; row < rowCount; row++) {
    if (locationTable.getString(row, currentColumn) != null && !locationTable.getString(row, currentColumn).isEmpty()) {
      int population = locationTable.getInt(row, currentColumn);
      if (population > maxPop) {
        maxPop = population;
      }
    }
  }
  return maxPop;
}

void mouseWheel(MouseEvent event) {
  float zoomFactor = 0.1;
  float delta = -event.getCount() * zoomFactor; // Negate the delta to reverse the zoom direction
  zoom += delta;
  zoom = constrain(zoom, 0.1, 10); // Limit zoom level
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    offsetX += mouseX - pmouseX;
    offsetY += mouseY - pmouseY;
  }
}


ArrayList<Integer> getAllPopulations() {
  ArrayList<Integer> populations = new ArrayList<Integer>();
  
  for (int row = 0; row < rowCount; row++) {
    if (locationTable.getString(row, currentColumn) != null && !locationTable.getString(row, currentColumn).isEmpty()) {
      int population = locationTable.getInt(row, currentColumn);
      populations.add(population);
    }
  }
  
  return populations;
}

ArrayList<Integer> getTopPopulations(int n) {
  ArrayList<Integer> populations = new ArrayList<Integer>();
  
  for (int row = 0; row < rowCount; row++) {
    if (locationTable.getString(row, currentColumn) != null && !locationTable.getString(row, currentColumn).isEmpty()) {
      int population = locationTable.getInt(row, currentColumn);
      populations.add(population);
    }
  }
  
  Collections.sort(populations, Collections.reverseOrder()); // Sort populations in descending order
  
  ArrayList<Integer> topNPopulations = new ArrayList<Integer>();
  
  // Add top n populations to the result list
  for (int i = 0; i < min(n, populations.size()); i++) {
    topNPopulations.add(populations.get(i));
  }
  
  return topNPopulations;
}
ArrayList<Integer> getLowestPopulations(int n) {
  ArrayList<Integer> populations = new ArrayList<Integer>();
  
  for (int row = 0; row < rowCount; row++) {
    if (locationTable.getString(row, currentColumn) != null && !locationTable.getString(row, currentColumn).isEmpty()) {
      int population = locationTable.getInt(row, currentColumn);
      populations.add(population);
    }
  }
  
  Collections.sort(populations); // Sort populations in ascending order
  
  ArrayList<Integer> lowestNPopulations = new ArrayList<Integer>();
  
  // Add lowest n populations to the result list
  for (int i = 0; i < Math.min(n, populations.size()); i++) {
    lowestNPopulations.add(populations.get(i));
  }
  
  return lowestNPopulations;
}

void keyPressed() {
  if (key == '4') {
    currentColumn = 3; // Switch to population from column 4 (2023)
    title = "2023"; // Set the title
  } else if (key == '5') {
    currentColumn = 4; // Switch to population from column 5 (2012)
    title = "2012"; // Set the title
  } else if (key == '6') {
    currentColumn = 5; // Switch to population from column 6 (2006)
    title = "2006"; // Set the title
  }  else if (key == '7') {
    showTop7 = !showTop7; // Toggle showTop7 variable
  }  else if (key == '8') {
    showLowest7 = !showLowest7; // Toggle showLowest7 variable
  }
}
