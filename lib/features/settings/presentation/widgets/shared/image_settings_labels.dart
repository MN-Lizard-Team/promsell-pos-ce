String qualityLabel(int quality) {
  if (quality <= 50) return 'Draft quality';
  if (quality <= 70) return 'Standard quality';
  if (quality <= 80) return 'High quality';
  if (quality <= 90) return 'Best quality';
  return 'Original quality';
}

String widthLabel(int width) {
  if (width <= 400) return 'Small size';
  if (width <= 600) return 'Medium size';
  if (width <= 800) return 'Large size';
  if (width <= 1200) return 'Extra large size';
  return 'Full HD size';
}
