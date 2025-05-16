#!/bin/bash

# --- Configurazione ---
PLANTUML_JAR="plantuml.jar" # Assicurati che plantuml.jar sia in questa path o fornisci la path completa
OUTPUT_DIR="uml_images"     # Cartella dove salvare le immagini generate
PRIMARY_FORMAT="svg"        # Formato primario (svg per massima qualità)
FINAL_FORMAT="png"          # Formato finale delle immagini (svg o png)
DPI="300"                   # Risoluzione in DPI per immagini PNG (valori comuni: 150, 300, 600)

# --- Controllo dipendenze ---
if [ ! -f "$PLANTUML_JAR" ]; then
  echo "Errore: plantuml.jar non trovato in $(pwd)/$PLANTUML_JAR."
  echo "Scaricalo da https://plantuml.com/download e mettilo nella stessa directory dello script o aggiorna la variabile PLANTUML_JAR."
  exit 1
fi

if ! command -v java &>/dev/null; then
  echo "Errore: Java non è installato o non è nel PATH."
  exit 1
fi

if ! command -v convert &>/dev/null; then
  echo "Avviso: ImageMagick non è installato. Sarà utilizzato solo il formato SVG."
  FINAL_FORMAT="svg"
fi

if [ "$FINAL_FORMAT" != "svg" ] && [ "$FINAL_FORMAT" != "png" ]; then
  echo "Formato $FINAL_FORMAT non supportato per l'output finale. Usando svg."
  FINAL_FORMAT="svg"
fi

# Crea la directory di output se non esiste
mkdir -p "$OUTPUT_DIR"

# Funzione per generare un diagramma
# $1: nome base del file (senza estensione .puml)
# $2: contenuto del file PlantUML (stringa multiriga)
generate_diagram() {
  local base_name="$1"
  local puml_content="$2"
  local puml_file="${base_name}.puml"
  local svg_file="${OUTPUT_DIR}/${base_name}.svg"
  local final_file="${OUTPUT_DIR}/${base_name}.${FINAL_FORMAT}"

  echo "Generando diagramma ${base_name}..."
  echo -e "$puml_content" >"$puml_file"

  # Genera sempre in formato SVG per massima qualità
  java -jar "$PLANTUML_JAR" -tsvg "$puml_file" -o"$(pwd)/${OUTPUT_DIR}"

  if [ $? -eq 0 ]; then
    # Se il formato finale è PNG, converti da SVG a PNG ad alta risoluzione
    if [ "$FINAL_FORMAT" = "png" ] && [ "$PRIMARY_FORMAT" = "svg" ]; then
      echo "Convertendo in PNG ad alta risoluzione..."
      convert -density ${DPI} "$svg_file" -background none -trim "$final_file"

      if [ $? -eq 0 ]; then
        echo "Diagramma ${final_file} generato con successo."
        if [ "$final_file" != "$svg_file" ]; then
          rm "$svg_file" # Rimuovi il file SVG intermedio se diverso dal file finale
        fi
      else
        echo "Errore durante la conversione in PNG. Mantenendo il formato SVG."
        FINAL_FORMAT="svg"
      fi
    else
      echo "Diagramma ${final_file} generato con successo."
    fi

    rm "$puml_file"
  else
    echo "Errore durante la generazione di ${svg_file}."
  fi
}

# --- Dark Theme Skin Parameters ---
DARK_THEME='
skinparam backgroundColor #000001

skinparam defaultFontName Arial
skinparam defaultFontSize 12
skinparam defaultFontColor #FFFFFF

skinparam class {
    BackgroundColor #3D3D3D
    BorderColor #FFFFFF
    ArrowColor #FFFFFF
    FontColor #FFFFFF
}

skinparam note {
    BackgroundColor #3D3D3D
    BorderColor #FFFFFF
    FontColor #FFFFFF
}

skinparam arrow {
    Color #FFFFFF
}

skinparam stereotype {
    BackgroundColor #3D3D3D
    BorderColor #FFFFFF
    FontColor #FFFFFF
}

skinparam entity {
    BackgroundColor #3D3D3D
    BorderColor #FFFFFF
    FontColor #FFFFFF
}

skinparam diamond {
    BackgroundColor #3D3D3D
    BorderColor #FFFFFF
    FontColor #FFFFFF
}
'

# --- Definizioni dei Diagrammi PlantUML ---

# Figura 1: Classi Employee e Project
PUML_CLASSES_EMPLOYEE_PROJECT='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

class Employee {
  Code: String
  Surname: String
  Income: Currency
  Age: Integer
}

class Project {
  Name: String
  Budget: Currency
  DeliveryDate: Date
}
@enduml
'
generate_diagram "fig_classes_employee_project" "$PUML_CLASSES_EMPLOYEE_PROJECT"

# Figura 2: Esempi di Associazioni
PUML_ASSOCIATIONS_EXAMPLES='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

Student "*" -- "*" Course : "Takes >"
Student : "student"
Course : "course"

Employee_Res "1" -- "0..1" City : Residence

Employee_Work "*" -- "1" Office : "WorksIn >"
Employee_Work : "employee"
Office : "office"
@enduml
'
generate_diagram "fig_associations_examples" "$PUML_ASSOCIATIONS_EXAMPLES"

# Figura 3: Classe di Associazione Exam
PUML_ASSOCIATION_CLASS_EXAM='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

Student "*" -- "*" Course
(Student, Course) .. Exam

class Exam {
  Date: Date
  Degree: Integer
}
@enduml
'
generate_diagram "fig_association_class_exam" "$PUML_ASSOCIATION_CLASS_EXAM"

# Figura 4a: Associazione Ternaria
PUML_TERNARY_ASSOCIATION='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

class Supplier
class Product
class Dept
entity TernaryDiamond <<diamond>>

Supplier -- TernaryDiamond
Product -- TernaryDiamond
Dept -- TernaryDiamond

class Provision_AC {
  Quantity: Integer
}
TernaryDiamond .. Provision_AC : (association class)

note bottom of Provision_AC : (a) Associazione Ternaria con Classe di Associazione
@enduml
'
generate_diagram "fig_ternary_association" "$PUML_TERNARY_ASSOCIATION"

# Figura 4b: Reificazione
PUML_REIFICATION='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

class Supplier_R
class Product_R
class Dept_R

class Provision_R {
  Quantity: Integer
}

Provision_R -- Supplier_R
Provision_R -- Product_R
Provision_R -- Dept_R

note bottom of Provision_R : (b) Reificazione dell Associazione Ternaria
@enduml
'
generate_diagram "fig_reification" "$PUML_REIFICATION"

# Figura 5: Aggregazione e Composizione
PUML_AGGREGATION_COMPOSITION='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

Team "1" o-- "1..*" Technician : aggregation
Firm "1" *-- "1..*" Agency : composition
@enduml
'
generate_diagram "fig_aggregation_composition" "$PUML_AGGREGATION_COMPOSITION"

# Figura 6: Identificatori
PUML_IDENTIFIERS='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

class Car {
  Plate: String {id}
  Model: String
  Colour: String
}

class Person_ID {
  BirthDate: Date {id}
  Surname: String {id}
  Name: String {id}
  Address: String
}
@enduml
'
# Rinominato Person in Person_ID per evitare conflitti con la Figura 8
generate_diagram "fig_identifiers" "$PUML_IDENTIFIERS"

# Figura 7: Associazione Identificante
PUML_IDENTIFYING_ASSOCIATION='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

class Student_IdExt {
  Number: String {id}
  YearRegistration: Integer
  Surname: String
}

class University {
  Name: String {id}
  City: String
  Address: String
}

Student_IdExt "1..*" -- "1" University : "<<identifying>> Registration"
@enduml
'
# Rinominato Student in Student_IdExt per evitare conflitti
generate_diagram "fig_identifying_association" "$PUML_IDENTIFYING_ASSOCIATION"

# Figura 8: Generalizzazione
PUML_GENERALIZATION='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members

class Person {
  TaxCode: String {id}
  Surname: String
  Age: Integer
}
class Male {
  ArmyService: Boolean
}
class Female

Person <|-- Male
Person <|-- Female
note on link
  {disjoint, total}
end note


class Professional {
  VAT: String {id}
  Address: String
}
Person <|-- Professional
note right of Professional
  Un Professional è una Person
end note

class Lawyer {
  Field: String
}
class Engineer

Professional <|-- Lawyer
Professional <|-- Engineer
note on link
  {disjoint, partial}
end note
@enduml
'
generate_diagram "fig_generalization" "$PUML_GENERALIZATION"

# Figura 9: Esempio Complessivo (Slide 102)
PUML_OVERALL_EXAMPLE='
@startuml
'"$DARK_THEME"'
skinparam classAttributeIconSize 0
hide empty members
skinparam defaultFontSize 10

class Employee_Overall as "Employee" {
  Code {id}
  Surname
  Income
  Age
}

class Dept_Overall as "Dept." {
  Name {id}
  Phone
}

class Project_Overall as "Project" {
  Name {id}
  Budget
  DeliveryDate
}
note right of Project_Overall
  Projects in which
  employees work
end note


class Office_Overall as "Office" {
  City {id}
  Address
}

Employee_Overall "1..*" -- "0..1" Dept_Overall : IsAffiliatedTo // Cardinalità da slide/ERD
(Employee_Overall, Dept_Overall) .. Affiliation
class Affiliation {
 Date
}


Employee_Overall "*" -- "1..*" Project_Overall : Attendance

Dept_Overall "1" *-- "1..*" Office_Overall : "Composition <<identifying>>"

@enduml
'
# Nomi classi suffissati con _Overall per evitare conflitti se si generano tutti in un colpo solo
# e per chiarezza nel codice PlantUML. L'alias "Nome Originale" gestisce il nome visualizzato.
generate_diagram "fig_overall_example_slide102" "$PUML_OVERALL_EXAMPLE"

echo ""
echo "--- Generazione completata ---"
echo "Immagini salvate in: $OUTPUT_DIR"
echo "Assicurati di avere plantuml.jar nella directory $(pwd) o aggiorna la variabile PLANTUML_JAR nello script."
echo "Assicurati che Java e Graphviz (consigliato) siano installati."
