SXSSFWorkbook swb=null;
Sheet sh=null;
InputStream inp=null;
Workbook wb=null;

String[][] importExcel(String filepath) {
  String[][] temp;
  
  try {
    inp = new FileInputStream(filepath);
  } catch(Exception e) {}
  
  try {
    wb = WorkbookFactory.create(inp);
  } catch(Exception e) {}
  
  Sheet sheet = wb.getSheetAt(0);
  int sizeX = sheet.getLastRowNum() + 1;
  int sizeY = 100;
  
  for (int i=0;i<sizeX;++i) {
    Row row = sheet.getRow(i);
    for (int j=0;j<sizeY;++j) {
      try {
        Cell cell = row.getCell(j);
      } catch(Exception e) {
        if (j>sizeY) {
          sizeY = j;
        }
      }
    }
  }
  
  temp = new String[sizeX][sizeY];
  for (int i=0;i<sizeX;++i) {
    for (int j=0;j<sizeY;++j) {
      Row row = sheet.getRow(i);
      try {
        Cell cell = row.getCell(j);
        if (cell.getCellType()==0 || cell.getCellType()==2 || cell.getCellType()==3)cell.setCellType(1);
        temp[i][j] = cell.getStringCellValue();
      } catch(Exception e) {}
    }
  }
  
  println("Excel file imported: " + filepath + " successfully!");
  return temp;
}
