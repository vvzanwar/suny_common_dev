const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const fields = [
  'Program_Status',
  'Approval_Status',
  'Approval_Date',
  'Approval_Source',
  'Suspension_Affirmation',
  'Program_Code',
  'Program_Type',
  'Award_Type',
  'Parent_Program',
  'Campus_Department',
  'Program_Cost',
  'Program_Fee',
  'Additional_Fees',
  'Financial_Aid_Applicable',
  'Early_Bird_Applicable',
  'First_Offered_Date',
  'Participation_Agreement_Expiry',
  'Early_Bird_End_Date',
  'Early_Bird_Start_Date'
];

const outDir = path.join(__dirname, 'raw_metadata');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

console.log('Fetching metadata for fields...');
for (const f of fields) {
  const filePath = path.join(outDir, `${f}.json`);
  if (fs.existsSync(filePath)) {
    console.log(`Already fetched ${f}`);
    continue;
  }
  console.log(`Fetching ${f}...`);
  try {
    const cmd = `sf data query --use-tooling-api --query "SELECT DeveloperName, Metadata FROM CustomField WHERE TableEnumOrId = 'LearningProgram' AND DeveloperName = '${f}'" --json`;
    const res = execSync(cmd, { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 });
    const json = JSON.parse(res);
    const rec = json.result.records[0];
    fs.writeFileSync(filePath, JSON.stringify(rec, null, 2), 'utf8');
    console.log(`Saved ${f}.json`);
  } catch (err) {
    console.error(`Failed ${f}:`, err.message);
  }
}
console.log('Done fetching all fields.');
