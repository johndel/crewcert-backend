# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# =============================================================================
# SUPER ADMINS
# =============================================================================
%w[istoselidas@gmail.com dimitris@intoolecta.com].each do |email|
  SuperAdmin.find_or_create_by!(email: email)
  puts "Created super admin: #{email}"
end

# =============================================================================
# ROLES
# =============================================================================
puts "Creating roles..."

ROLES = [
  # Deck Officers
  { name: "Master", position: 1 },
  { name: "Chief Officer", position: 2 },
  { name: "Second Officer", position: 3 },
  { name: "Third Officer", position: 4 },
  { name: "Apprentice Officer", position: 5 },
  # Engine Officers
  { name: "Chief Engineer", position: 6 },
  { name: "Second Engineer", position: 7 },
  { name: "Third Engineer", position: 8 },
  { name: "Fourth Engineer", position: 9 },
  { name: "Apprentice Engineer", position: 10 },
  # Ratings
  { name: "AB (Able-Bodied) Seaman", position: 11 },
  { name: "Ordinary Seaman", position: 12 },
  { name: "Fitter", position: 13 },
  { name: "Oiler", position: 14 },
  { name: "Wiper", position: 15 },
  { name: "Electronic Engineer", position: 16 },
  { name: "Electrician", position: 17 },
  { name: "Apprentice Electrician", position: 18 },
  { name: "Bosun", position: 19 },
  { name: "Chief Cook", position: 20 },
  { name: "Messman", position: 21 },
  { name: "Messboy", position: 22 },
  { name: "Deck Cadet", position: 23 },
  { name: "Engine Cadet", position: 24 }
].freeze

roles = {}
ROLES.each do |role_data|
  role = Role.find_or_create_by!(name: role_data[:name]) do |r|
    r.position = role_data[:position]
  end
  roles[role.name] = role
end

puts "Created #{Role.count} roles"

# =============================================================================
# CERTIFICATE TYPES
# =============================================================================
puts "Creating certificate types..."

CERTIFICATE_TYPES = [
  # Common Training
  { code: "1001", name: "Ship's Garbage Management Plan & Garbage Record Book", validity_period_months: 60 },
  { code: "1002", name: "Ship's Garbage Management Plan", validity_period_months: 60 },
  { code: "1003", name: "Oil Record Book – Part I (Machinery Space)", validity_period_months: 60 },
  { code: "1004", name: "Enclosed Space Entry & Rescue", validity_period_months: 60 },
  { code: "1005", name: "Ship Safety Officer", validity_period_months: 60 },
  { code: "1006", name: "Guide on Safe Mooring Operations & Procedures", validity_period_months: 60 },
  { code: "1007", name: "Onboard Ship Assessment", validity_period_months: 60 },
  { code: "1010", name: "Safety Food Sanitation System", validity_period_months: 60 },
  { code: "1018", name: "Plans and procedures for recovery persons from the water", validity_period_months: 60 },
  { code: "1021", name: "Ship's SOLAS Training Manual (FFE) - Part I: Theory of fire (Opt)", validity_period_months: 60 },
  { code: "1022", name: "Ship's SOLAS Training Manual (FFE) - Part I: Theory of fire (Mng)", validity_period_months: 60 },
  { code: "1023", name: "Ship's SOLAS Training Manual (FFE) - Part II: Structural Fire Protection", validity_period_months: 60 },
  { code: "1024", name: "Ship's SOLAS Training Manual (FFE) - Part III: Fire Fighting Equipment", validity_period_months: 60 },
  { code: "1025", name: "Structure & Function of human body", validity_period_months: 60 },
  { code: "1026", name: "Hospital set-up & patient's treatment (Examination Procedures)", validity_period_months: 60 },
  { code: "1027", name: "Emergency First Aid", validity_period_months: 60 },
  { code: "1028", name: "Medical First Aid: Accidents and treatment", validity_period_months: 60 },
  { code: "1029", name: "Train the Trainer – STCW Part B", validity_period_months: 60 },
  { code: "1030", name: "Presentation Skills", validity_period_months: 60 },
  { code: "1031", name: "Port State Control Inspections", validity_period_months: 60 },
  { code: "1032", name: "Port State Control: Raising Awareness", validity_period_months: 60 },
  { code: "1033", name: "Port State Control: AMSA & USCG", validity_period_months: 60 },
  { code: "1034", name: "Fuel Oil Changeover Procedures", validity_period_months: 60 },
  { code: "1035", name: "Fuel Bunkering operations", validity_period_months: 60 },
  { code: "1043", name: "Behavior Based Safety", validity_period_months: 60 },
  { code: "1044", name: "Fatigue Awareness and Management", validity_period_months: 60 },
  { code: "1045", name: "Cyber Security Onboard", validity_period_months: 60 },
  { code: "1046", name: "Use of PPE", validity_period_months: 60 },
  { code: "1047", name: "MLC 2006 - Ratings", validity_period_months: 60 },
  { code: "1048", name: "MLC 2006 - Officers", validity_period_months: 60 },
  { code: "1049", name: "ECDIS System & Electronic chart types", validity_period_months: 60 },
  { code: "1051", name: "Voyage Planning & Route monitoring with ECDIS", validity_period_months: 60 },
  { code: "1059", name: "Bunker Fuels Ops & Malpractices", validity_period_months: 60 },
  { code: "1060", name: "Vessel's Maintenance", validity_period_months: 60 },
  { code: "1062", name: "IMO Sulphur Cap 2020", validity_period_months: 60 },
  { code: "1063", name: "Health and hygiene", validity_period_months: 60 },
  { code: "1064", name: "Housekeeping", validity_period_months: 60 },
  { code: "1065", name: "Food Safety", validity_period_months: 60 },
  { code: "1067", name: "Coronavirus Disease (COVID-19) Awareness", validity_period_months: 60 },
  { code: "1080", name: "Basic Life Support", validity_period_months: 60 },
  { code: "1087", name: "Orthopedic Emergencies", validity_period_months: 60 },

  # Wet/Technical
  { code: "2005", name: "STS Transfer Operation (TNK)", validity_period_months: 60 },
  { code: "4003", name: "Oily Water Separator", validity_period_months: 60 },
  { code: "4005", name: "Familiarization with High Voltage", validity_period_months: 60 },
  { code: "4016", name: "Ballast Water Management - Legislation", validity_period_months: 60 },
  { code: "4017", name: "Ballast Water Treatment - Technologies", validity_period_months: 60 },
  { code: "4018", name: "Ballast Water Treatment - Operation", validity_period_months: 60 },
  { code: "4019", name: "Ballast Water Treatment - Maintenance & Troubleshooting", validity_period_months: 60 },
  { code: "4020", name: "Ballast Water Management - Compliance, Monitoring & Enforcement", validity_period_months: 60 },

  # Lessons Learnt
  { code: "5001", name: "Lessons learnt - Mooring incident I: Operation with a tugboat", validity_period_months: 60 },
  { code: "5002", name: "Lessons learnt – Grounding incident", validity_period_months: 60 },
  { code: "5003", name: "Lessons learnt - Mooring incident II: Parted spring line", validity_period_months: 60 },
  { code: "5004", name: "Lessons learnt - Safety food sanitation incident", validity_period_months: 60 },
  { code: "5005", name: "Lessons learnt - Enclosed space entry and rescue incident", validity_period_months: 60 },
  { code: "5006", name: "Lessons learnt - Ship Safety Officer incident", validity_period_months: 60 },
  { code: "5007", name: "Lessons Learnt - Incident during a routine maintenance", validity_period_months: 60 },
  { code: "5008", name: "Lessons Learnt - Recovery of persons from water incident", validity_period_months: 60 },
  { code: "5009", name: "Lessons learnt - Marine Environmental Awareness Incident", validity_period_months: 60 },
  { code: "5010", name: "Lessons learnt - Contact with barge incident", validity_period_months: 60 },
  { code: "5011", name: "Lessons learnt - Vessel touched bottom in Suez Canal Incident", validity_period_months: 60 },

  # Resilience
  { code: "6001", name: "Resilience - Module 1: Change is a part of living", validity_period_months: 60 },
  { code: "6002", name: "Resilience - Module 2: Keep things in perspective", validity_period_months: 60 },
  { code: "6003", name: "Resilience - Module 3: Take decisive action", validity_period_months: 60 },
  { code: "6004", name: "Resilience - Module 4: Take care of yourself", validity_period_months: 60 },
  { code: "6005", name: "Resilience - Module 5: What is resilience?", validity_period_months: 60 },
  { code: "6006", name: "Resilience - Module 6: Dealing with crises", validity_period_months: 60 },
  { code: "6007", name: "Resilience - Module 7: Making connections", validity_period_months: 60 },
  { code: "6008", name: "Resilience - Module 8: Maintain a hopeful outlook", validity_period_months: 60 },
  { code: "6009", name: "Resilience - Module 9: Connections to home", validity_period_months: 60 },
  { code: "6010", name: "Resilience - Module 10: Gratitude", validity_period_months: 60 },
  { code: "6011", name: "Resilience - Module 11: Positive Communication", validity_period_months: 60 },

  # Company Training
  { code: "7001", name: "Company Security Officer", validity_period_months: 60 },
  { code: "7022", name: "Cyber Security", validity_period_months: 60 },
  { code: "7023", name: "GDPR: from theory to practice", validity_period_months: 60 },

  # VR Training
  { code: "8001", name: "How to test the Emergency Generator", validity_period_months: 60 },
  { code: "8002", name: "Fire in the Engine Control Room", validity_period_months: 60 },
  { code: "8004", name: "Lifeboat Drill Procedure", validity_period_months: 60 },

  # Let's Talk
  { code: "9001", name: "Let's Talk - Module 1: We all have a state of mental health", validity_period_months: 60 },
  { code: "9002", name: "Let's Talk - Module 2: Support Structures", validity_period_months: 60 },
  { code: "9003", name: "Let's Talk - Module 3: ALL ACT - Supporting Others", validity_period_months: 60 }
].freeze

certificate_types = {}
CERTIFICATE_TYPES.each do |ct_data|
  ct = CertificateType.find_or_create_by!(code: ct_data[:code]) do |c|
    c.name = ct_data[:name]
    c.validity_period_months = ct_data[:validity_period_months]
  end
  certificate_types[ct.code] = ct
end

puts "Created #{CertificateType.count} certificate types"

# =============================================================================
# TRAINING MATRIX (Default requirements)
# =============================================================================
puts "Creating default training matrix..."

# Role name shortcuts
MASTER = "Master"
CHIEF_OFF = "Chief Officer"
SECOND_OFF = "Second Officer"
THIRD_OFF = "Third Officer"
APP_OFF = "Apprentice Officer"
CHIEF_ENG = "Chief Engineer"
SECOND_ENG = "Second Engineer"
THIRD_ENG = "Third Engineer"
FOURTH_ENG = "Fourth Engineer"
APP_ENG = "Apprentice Engineer"
AB = "AB (Able-Bodied) Seaman"
OS = "Ordinary Seaman"
FITTER = "Fitter"
OILER = "Oiler"
WIPER = "Wiper"
ELEC_ENG = "Electronic Engineer"
ELEC = "Electrician"
APP_ELEC = "Apprentice Electrician"
BOSUN = "Bosun"
COOK = "Chief Cook"
MESSMAN = "Messman"
MESSBOY = "Messboy"
DECK_CADET = "Deck Cadet"
ENG_CADET = "Engine Cadet"

# All deck officers
DECK_OFFICERS = [MASTER, CHIEF_OFF, SECOND_OFF, THIRD_OFF, APP_OFF].freeze
# All engine officers
ENGINE_OFFICERS = [CHIEF_ENG, SECOND_ENG, THIRD_ENG, FOURTH_ENG, APP_ENG].freeze
# All officers
ALL_OFFICERS = DECK_OFFICERS + ENGINE_OFFICERS
# All ratings
ALL_RATINGS = [AB, OS, FITTER, OILER, WIPER, ELEC_ENG, ELEC, APP_ELEC, BOSUN, COOK, MESSMAN, MESSBOY, DECK_CADET, ENG_CADET].freeze
# All roles
ALL_ROLES = ALL_OFFICERS + ALL_RATINGS

# Training matrix data: { certificate_code => { role_name => requirement_level } }
# M = Mandatory, O = Optional
TRAINING_MATRIX = {
  # Common Training - Page 1
  "1001" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", APP_ENG => "M" },
  "1002" => ALL_RATINGS.to_h { |r| [r, "M"] },
  "1003" => { MASTER => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", APP_ENG => "M" },
  "1004" => ALL_ROLES.to_h { |r| [r, "M"] }.merge({ APP_ELEC => "O", COOK => "O" }),
  "1005" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M" },
  "1006" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "O", SECOND_ENG => "O", THIRD_ENG => "O", FOURTH_ENG => "O", APP_ENG => "O", AB => "M", OS => "M", FITTER => "O", OILER => "O", WIPER => "O", ELEC_ENG => "O", ELEC => "O", APP_ELEC => "O", BOSUN => "M", COOK => "O", MESSMAN => "O", MESSBOY => "O", DECK_CADET => "M", ENG_CADET => "O" },
  "1007" => { MASTER => "M", CHIEF_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", ELEC_ENG => "M", ELEC => "M", BOSUN => "M" },
  "1010" => { BOSUN => "M", COOK => "M", MESSMAN => "M" },
  "1018" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1021" => ALL_RATINGS.to_h { |r| [r, "M"] },
  "1022" => ALL_OFFICERS.to_h { |r| [r, "M"] },
  "1023" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1024" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1025" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1026" => ALL_ROLES.to_h { |r| [r, "O"] }.merge(DECK_OFFICERS.to_h { |r| [r, "M"] }),
  "1027" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1028" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1029" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", BOSUN => "M" },
  "1030" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", BOSUN => "M" },
  "1031" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", APP_ENG => "M" },
  "1032" => ALL_RATINGS.to_h { |r| [r, "M"] },
  "1033" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1034" => { MASTER => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", OILER => "M", FITTER => "M", WIPER => "M", ENG_CADET => "M" },
  "1035" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", AB => "M", OS => "M", FITTER => "M", OILER => "M", WIPER => "M", BOSUN => "M", DECK_CADET => "M", ENG_CADET => "M" },
  "1043" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1044" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1045" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1046" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1047" => (ALL_RATINGS - [DECK_CADET, ENG_CADET]).to_h { |r| [r, "M"] }.merge({ CHIEF_ENG => "M" }),
  "1048" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "O", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", APP_ENG => "O" },
  "1049" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", ELEC_ENG => "M", DECK_CADET => "M" },

  # Page 2
  "1051" => DECK_OFFICERS.to_h { |r| [r, "M"] }.merge({ DECK_CADET => "M" }),
  "1059" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", DECK_CADET => "M" },
  "1060" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", AB => "M", OS => "M", BOSUN => "M", DECK_CADET => "M" },
  "1062" => { MASTER => "O", CHIEF_OFF => "O", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M" },
  "1063" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1064" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1065" => { COOK => "M", MESSMAN => "M", MESSBOY => "M" },
  "1067" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1080" => ALL_ROLES.to_h { |r| [r, "M"] },
  "1087" => ALL_ROLES.to_h { |r| [r, "M"] },

  # Wet/Technical
  "2005" => DECK_OFFICERS.to_h { |r| [r, "M"] }.merge({ AB => "M", OS => "M", BOSUN => "M", DECK_CADET => "M" }),
  "4003" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "M", FOURTH_ENG => "M", ELEC_ENG => "M", ELEC => "M", ENG_CADET => "O" },
  "4005" => ENGINE_OFFICERS.to_h { |r| [r, "M"] }.merge({ ELEC_ENG => "M", ELEC => "M" }),
  "4016" => ALL_ROLES.to_h { |r| [r, "O"] }.merge(ALL_OFFICERS.to_h { |r| [r, "M"] }),
  "4017" => ALL_ROLES.to_h { |r| [r, "O"] }.merge(ALL_OFFICERS.to_h { |r| [r, "M"] }),
  "4018" => ALL_ROLES.to_h { |r| [r, "O"] }.merge(ALL_OFFICERS.to_h { |r| [r, "M"] }).merge({ APP_OFF => "M", APP_ENG => "O" }),
  "4019" => ALL_ROLES.to_h { |r| [r, "O"] }.merge(ALL_OFFICERS.to_h { |r| [r, "M"] }),
  "4020" => ALL_ROLES.to_h { |r| [r, "O"] }.merge(ALL_OFFICERS.to_h { |r| [r, "M"] }),

  # Lessons Learnt
  "5001" => DECK_OFFICERS.to_h { |r| [r, "M"] },
  "5002" => DECK_OFFICERS.to_h { |r| [r, "M"] },
  "5003" => DECK_OFFICERS.to_h { |r| [r, "M"] },
  "5004" => { BOSUN => "M", COOK => "M", MESSMAN => "M" },
  "5005" => ALL_ROLES.to_h { |r| [r, "M"] },
  "5006" => DECK_OFFICERS.to_h { |r| [r, "M"] }.except(APP_OFF),
  "5007" => ALL_ROLES.to_h { |r| [r, "M"] },
  "5008" => ALL_ROLES.to_h { |r| [r, "M"] },
  "5009" => ALL_ROLES.to_h { |r| [r, "M"] },
  "5010" => ALL_ROLES.to_h { |r| [r, "M"] },
  "5011" => { MASTER => "M", CHIEF_OFF => "M", SECOND_OFF => "M", THIRD_OFF => "M", APP_OFF => "M", CHIEF_ENG => "M", SECOND_ENG => "M", THIRD_ENG => "O", FOURTH_ENG => "O", APP_ENG => "O", AB => "M", OS => "O", BOSUN => "M", DECK_CADET => "M" },

  # Resilience Modules
  "6001" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6002" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6003" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6004" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6005" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6006" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6007" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6008" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6009" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6010" => ALL_ROLES.to_h { |r| [r, "M"] },
  "6011" => ALL_ROLES.to_h { |r| [r, "M"] },

  # VR Training
  "8001" => ALL_ROLES.to_h { |r| [r, "M"] },
  "8002" => ALL_ROLES.to_h { |r| [r, "M"] },
  "8004" => ALL_ROLES.to_h { |r| [r, "M"] },

  # Let's Talk
  "9001" => ALL_ROLES.to_h { |r| [r, "M"] },
  "9002" => ALL_ROLES.to_h { |r| [r, "M"] },
  "9003" => ALL_ROLES.to_h { |r| [r, "M"] }
}.freeze

# =============================================================================
# SAMPLE VESSEL WITH MATRIX
# =============================================================================
puts "Creating sample vessel..."

sample_vessel = Vessel.find_or_create_by!(name: "M/V Sample Vessel") do |v|
  v.imo = "IMO1234567"
  v.management_company = "CrewCert Maritime Ltd."
end

puts "Creating matrix requirements for sample vessel..."

matrix_count = 0
TRAINING_MATRIX.each do |cert_code, role_requirements|
  cert_type = certificate_types[cert_code]
  next unless cert_type

  role_requirements.each do |role_name, level|
    role = roles[role_name]
    next unless role

    MatrixRequirement.find_or_create_by!(
      vessel: sample_vessel,
      role: role,
      certificate_type: cert_type
    ) do |mr|
      mr.requirement_level = level
    end
    matrix_count += 1
  end
end

puts "Created #{matrix_count} matrix requirements"

# =============================================================================
# ADMIN USERS
# =============================================================================
puts "Creating admin users..."

[
  { email: "istoselidas@gmail.com", first_name: "Giannis", last_name: "Stoselidas" },
  { email: "dimitris@intoolecta.com", first_name: "Dimitris", last_name: "Intoolecta" }
].each do |user_data|
  user = User.find_or_create_by!(email: user_data[:email]) do |u|
    u.first_name = user_data[:first_name]
    u.last_name = user_data[:last_name]
  end
  puts "Admin user created: #{user.email}"
end

# =============================================================================
# SAMPLE CREW MEMBERS
# =============================================================================
puts "Creating sample crew members..."

sample_crew = [
  { first_name: "John", last_name: "Smith", email: "john.smith@example.com", role: "Master" },
  { first_name: "Maria", last_name: "Garcia", email: "maria.garcia@example.com", role: "Chief Officer" },
  { first_name: "James", last_name: "Johnson", email: "james.johnson@example.com", role: "Chief Engineer" },
  { first_name: "Anna", last_name: "Williams", email: "anna.williams@example.com", role: "Second Engineer" },
  { first_name: "Michael", last_name: "Brown", email: "michael.brown@example.com", role: "AB (Able-Bodied) Seaman" },
  { first_name: "Elena", last_name: "Martinez", email: "elena.martinez@example.com", role: "Chief Cook" }
]

sample_crew.each do |crew_data|
  role = roles[crew_data[:role]]
  CrewMember.find_or_create_by!(email: crew_data[:email]) do |cm|
    cm.first_name = crew_data[:first_name]
    cm.last_name = crew_data[:last_name]
    cm.vessel = sample_vessel
    cm.role = role
  end
end

puts "Created #{CrewMember.count} crew members"

puts "Seeding completed!"
puts "Summary:"
puts "  - #{Role.count} roles"
puts "  - #{CertificateType.count} certificate types"
puts "  - #{Vessel.count} vessels"
puts "  - #{MatrixRequirement.count} matrix requirements"
puts "  - #{User.count} admin users"
puts "  - #{CrewMember.count} crew members"
