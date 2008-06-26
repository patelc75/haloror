REM Copy this file to RAILS_ROOT directory before running!

REM DOS batch file to generate schema diagram with Railroad
REM See http://www.assembla.com/wiki/show/haloror/Schema_diagram_with_Railroad

railroad -a -i -M | dot -Tpng > db\models.png
