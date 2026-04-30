"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TrainingPlanExcelService = void 0;
const exceljs_1 = __importDefault(require("exceljs"));
class TrainingPlanExcelService {
    /**
     * Generate an Excel file from a training plan using the template
     */
    generateFromTemplate(trainingPlan, options) {
        return __awaiter(this, void 0, void 0, function* () {
            const workbook = new exceljs_1.default.Workbook();
            yield workbook.xlsx.readFile(options.templatePath);
            // Get the Resistance Training sheet
            const sheet = workbook.getWorksheet('Resistance Training');
            if (!sheet) {
                throw new Error('Resistance Training sheet not found in template');
            }
            // Populate client info
            if (options.clientName) {
                sheet.getCell('D3').value = options.clientName;
            }
            if (options.startDate) {
                sheet.getCell('D4').value = options.startDate;
            }
            if (options.weekOnProgramme) {
                sheet.getCell('D5').value = options.weekOnProgramme;
            }
            // Day positions in the template (row where exercises start)
            const dayConfig = [
                { headerRow: 7, startRow: 9, maxExercises: 14 }, // DAY 1
                { headerRow: 25, startRow: 27, maxExercises: 14 }, // DAY 2
                { headerRow: 43, startRow: 45, maxExercises: 14 }, // DAY 3
                { headerRow: 61, startRow: 63, maxExercises: 14 }, // DAY 4
                { headerRow: 79, startRow: 81, maxExercises: 14 }, // DAY 5
            ];
            // Populate each day
            trainingPlan.days.forEach((day, dayIndex) => {
                if (dayIndex >= dayConfig.length)
                    return;
                const config = dayConfig[dayIndex];
                // Update day name in header if needed
                const dayNameCell = sheet.getCell(`B${config.headerRow}`);
                if (day.name && day.name !== `DAY ${dayIndex + 1}`) {
                    dayNameCell.value = day.name;
                }
                // Populate exercises
                day.exercises.forEach((exercise, exerciseIndex) => {
                    if (exerciseIndex >= config.maxExercises)
                        return;
                    const row = config.startRow + exerciseIndex;
                    // Column B: ORDER (can be left empty or set index)
                    // Column C: EXERCISE
                    sheet.getCell(`C${row}`).value = exercise.name;
                    // Column D: SETS
                    sheet.getCell(`D${row}`).value = exercise.sets.length;
                    // Column E: REPS - format as range or list
                    const repsValues = exercise.sets.map((s) => s.reps);
                    const repsStr = this.formatReps(repsValues);
                    sheet.getCell(`E${row}`).value = repsStr;
                    // Column F: TEMPO (using seconds/minutes as tempo indicator)
                    // Template uses format like "3 0 1 1" - we can derive from timing
                    sheet.getCell(`F${row}`).value = 3; // Default tempo
                    // Column J: INTENSITY (RIR - Reps in Reserve)
                    const rirValues = exercise.sets.map((s) => s.rir);
                    const avgRir = rirValues.reduce((a, b) => a + b, 0) / rirValues.length;
                    sheet.getCell(`J${row}`).value = `RIR ${Math.round(avgRir)}`;
                    // Column K: NOTES (body parts)
                    sheet.getCell(`K${row}`).value = exercise.bodyParts.join(', ');
                    // Column L: VIDEO LINK
                    if (exercise.videoUrl) {
                        const cell = sheet.getCell(`L${row}`);
                        cell.value = {
                            text: 'Watch Video',
                            hyperlink: exercise.videoUrl,
                        };
                        cell.font = { color: { argb: 'FF0000FF' }, underline: true };
                    }
                });
            });
            // Save the workbook
            yield workbook.xlsx.writeFile(options.outputPath);
            return options.outputPath;
        });
    }
    /**
     * Generate an Excel Buffer from a training plan using the template
     * Returns a Buffer that can be uploaded to Cloudinary
     */
    generateBufferFromTemplate(trainingPlan, options) {
        return __awaiter(this, void 0, void 0, function* () {
            const workbook = new exceljs_1.default.Workbook();
            yield workbook.xlsx.readFile(options.templatePath);
            // Get the Resistance Training sheet
            const sheet = workbook.getWorksheet('Resistance Training');
            if (!sheet) {
                throw new Error('Resistance Training sheet not found in template');
            }
            // Populate client info
            if (options.clientName) {
                sheet.getCell('D3').value = options.clientName;
            }
            if (options.startDate) {
                sheet.getCell('D4').value = options.startDate;
            }
            if (options.weekOnProgramme) {
                sheet.getCell('D5').value = options.weekOnProgramme;
            }
            // Day positions in the template (row where exercises start)
            const dayConfig = [
                { headerRow: 7, startRow: 9, maxExercises: 14 }, // DAY 1
                { headerRow: 25, startRow: 27, maxExercises: 14 }, // DAY 2
                { headerRow: 43, startRow: 45, maxExercises: 14 }, // DAY 3
                { headerRow: 61, startRow: 63, maxExercises: 14 }, // DAY 4
                { headerRow: 79, startRow: 81, maxExercises: 14 }, // DAY 5
            ];
            // Populate each day
            trainingPlan.days.forEach((day, dayIndex) => {
                if (dayIndex >= dayConfig.length)
                    return;
                const config = dayConfig[dayIndex];
                // Update day name in header if needed
                const dayNameCell = sheet.getCell(`B${config.headerRow}`);
                if (day.name && day.name !== `DAY ${dayIndex + 1}`) {
                    dayNameCell.value = day.name;
                }
                // Populate exercises
                day.exercises.forEach((exercise, exerciseIndex) => {
                    if (exerciseIndex >= config.maxExercises)
                        return;
                    const row = config.startRow + exerciseIndex;
                    // Column B: ORDER (can be left empty or set index)
                    // Column C: EXERCISE
                    sheet.getCell(`C${row}`).value = exercise.name;
                    // Column D: SETS
                    sheet.getCell(`D${row}`).value = exercise.sets.length;
                    // Column E: REPS - format as range or list
                    const repsValues = exercise.sets.map((s) => s.reps);
                    const repsStr = this.formatReps(repsValues);
                    sheet.getCell(`E${row}`).value = repsStr;
                    // Column F: TEMPO (using seconds/minutes as tempo indicator)
                    // Template uses format like "3 0 1 1" - we can derive from timing
                    sheet.getCell(`F${row}`).value = 3; // Default tempo
                    // Column J: INTENSITY (RIR - Reps in Reserve)
                    const rirValues = exercise.sets.map((s) => s.rir);
                    const avgRir = rirValues.reduce((a, b) => a + b, 0) / rirValues.length;
                    sheet.getCell(`J${row}`).value = `RIR ${Math.round(avgRir)}`;
                    // Column K: NOTES (body parts)
                    sheet.getCell(`K${row}`).value = exercise.bodyParts.join(', ');
                    // Column L: VIDEO LINK
                    if (exercise.videoUrl) {
                        const cell = sheet.getCell(`L${row}`);
                        cell.value = {
                            text: 'Watch Video',
                            hyperlink: exercise.videoUrl,
                        };
                        cell.font = { color: { argb: 'FF0000FF' }, underline: true };
                    }
                });
            });
            // Return buffer instead of writing to file
            const buffer = yield workbook.xlsx.writeBuffer();
            return Buffer.from(buffer);
        });
    }
    /**
     * Create a new Excel file from scratch (without template)
     */
    generateNew(trainingPlan, outputPath, clientName) {
        return __awaiter(this, void 0, void 0, function* () {
            const workbook = new exceljs_1.default.Workbook();
            workbook.creator = 'Training Plan Generator';
            workbook.created = new Date();
            // Create main sheet
            const sheet = workbook.addWorksheet('Resistance Training', {
                properties: { tabColor: { argb: 'FF00FF00' } },
            });
            // Set column widths
            sheet.columns = [
                { header: '', key: 'spacer', width: 3 },
                { header: 'ORDER', key: 'order', width: 8 },
                { header: 'EXERCISE', key: 'exercise', width: 35 },
                { header: 'SETS', key: 'sets', width: 8 },
                { header: 'REPS', key: 'reps', width: 15 },
                { header: 'WEIGHT (kg)', key: 'weight', width: 12 },
                { header: 'RIR', key: 'rir', width: 8 },
                { header: 'BODY PARTS', key: 'bodyParts', width: 20 },
                { header: 'VIDEO', key: 'video', width: 15 },
            ];
            // Title
            sheet.mergeCells('B1:I1');
            const titleCell = sheet.getCell('B1');
            titleCell.value = trainingPlan.name || 'TRAINING PLAN';
            titleCell.font = { bold: true, size: 18 };
            titleCell.alignment = { horizontal: 'center' };
            // Client info
            if (clientName) {
                sheet.getCell('B2').value = 'CLIENT:';
                sheet.getCell('C2').value = clientName;
            }
            // Last updated
            if (trainingPlan.lastUpdated) {
                sheet.getCell('B3').value = 'LAST UPDATED:';
                sheet.getCell('C3').value = trainingPlan.lastUpdated.toLocaleDateString();
            }
            // Body parts covered
            sheet.getCell('B4').value = 'BODY PARTS:';
            sheet.getCell('C4').value = trainingPlan.bodyParts.join(', ');
            let currentRow = 6;
            // Add each day
            trainingPlan.days.forEach((day, dayIndex) => {
                // Day header
                sheet.mergeCells(`B${currentRow}:I${currentRow}`);
                const dayHeader = sheet.getCell(`B${currentRow}`);
                dayHeader.value = day.name || `DAY ${dayIndex + 1}`;
                dayHeader.font = { bold: true, size: 14, color: { argb: 'FFFFFFFF' } };
                dayHeader.fill = {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: 'FF2F5496' },
                };
                dayHeader.alignment = { horizontal: 'center' };
                currentRow++;
                // Column headers
                const headerRow = sheet.getRow(currentRow);
                headerRow.values = [
                    '',
                    '#',
                    'EXERCISE',
                    'SETS',
                    'REPS',
                    'WEIGHT (kg)',
                    'RIR',
                    'BODY PARTS',
                    'VIDEO',
                ];
                headerRow.font = { bold: true };
                headerRow.eachCell((cell, colNumber) => {
                    if (colNumber > 1) {
                        cell.fill = {
                            type: 'pattern',
                            pattern: 'solid',
                            fgColor: { argb: 'FFD9E2F3' },
                        };
                        cell.border = {
                            top: { style: 'thin' },
                            left: { style: 'thin' },
                            bottom: { style: 'thin' },
                            right: { style: 'thin' },
                        };
                    }
                });
                currentRow++;
                // Exercises
                day.exercises.forEach((exercise, exerciseIndex) => {
                    const row = sheet.getRow(currentRow);
                    // Format sets data
                    const repsStr = this.formatReps(exercise.sets.map((s) => s.reps));
                    const weightStr = this.formatWeights(exercise.sets.map((s) => s.weight));
                    const rirStr = this.formatRir(exercise.sets.map((s) => s.rir));
                    row.values = [
                        '',
                        exerciseIndex + 1,
                        exercise.name,
                        exercise.sets.length,
                        repsStr,
                        weightStr,
                        rirStr,
                        exercise.bodyParts.join(', '),
                        exercise.videoUrl ? 'Link' : '',
                    ];
                    // Add hyperlink for video
                    if (exercise.videoUrl) {
                        const videoCell = row.getCell(9);
                        videoCell.value = {
                            text: 'Watch',
                            hyperlink: exercise.videoUrl,
                        };
                        videoCell.font = { color: { argb: 'FF0000FF' }, underline: true };
                    }
                    // Style cells
                    row.eachCell((cell, colNumber) => {
                        if (colNumber > 1) {
                            cell.border = {
                                top: { style: 'thin' },
                                left: { style: 'thin' },
                                bottom: { style: 'thin' },
                                right: { style: 'thin' },
                            };
                        }
                    });
                    currentRow++;
                });
                // Add spacing between days
                currentRow += 2;
            });
            // Create a detailed sets sheet
            const setsSheet = workbook.addWorksheet('Detailed Sets');
            setsSheet.columns = [
                { header: 'Day', key: 'day', width: 15 },
                { header: 'Exercise', key: 'exercise', width: 35 },
                { header: 'Set #', key: 'setNumber', width: 8 },
                { header: 'Reps', key: 'reps', width: 8 },
                { header: 'Weight (kg)', key: 'weight', width: 12 },
                { header: 'RIR', key: 'rir', width: 8 },
            ];
            // Style header
            const setsHeaderRow = setsSheet.getRow(1);
            setsHeaderRow.font = { bold: true };
            setsHeaderRow.eachCell((cell) => {
                cell.fill = {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: 'FF2F5496' },
                };
                cell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
            });
            // Add detailed set data
            trainingPlan.days.forEach((day) => {
                day.exercises.forEach((exercise) => {
                    exercise.sets.forEach((set, setIndex) => {
                        setsSheet.addRow({
                            day: day.name,
                            exercise: exercise.name,
                            setNumber: setIndex + 1,
                            reps: set.reps,
                            weight: set.weight,
                            rir: set.rir,
                        });
                    });
                });
            });
            yield workbook.xlsx.writeFile(outputPath);
            return outputPath;
        });
    }
    /**
     * Format reps array into display string
     * Reps are now strings (can be ranges like "8-12" or single numbers)
     */
    formatReps(reps) {
        const unique = [...new Set(reps)];
        if (unique.length === 1) {
            return unique[0];
        }
        return reps.join(' / ');
    }
    /**
     * Format weights array into display string
     */
    formatWeights(weights) {
        const unique = [...new Set(weights)];
        if (unique.length === 1) {
            return String(unique[0]);
        }
        return weights.join(' / ');
    }
    /**
     * Format RIR array into display string
     */
    formatRir(rirs) {
        const unique = [...new Set(rirs)];
        if (unique.length === 1) {
            return String(unique[0]);
        }
        return rirs.join(' / ');
    }
    /**
     * Read an existing Excel and convert to TrainingPlan object
     */
    parseFromExcel(filePath) {
        return __awaiter(this, void 0, void 0, function* () {
            const workbook = new exceljs_1.default.Workbook();
            yield workbook.xlsx.readFile(filePath);
            const sheet = workbook.getWorksheet('Resistance Training');
            if (!sheet) {
                throw new Error('Resistance Training sheet not found');
            }
            const trainingPlan = {
                name: 'Imported Training Plan',
                days: [],
                bodyParts: [],
            };
            // Day positions in the template (row where header is)
            const dayMarkers = [7, 25, 43, 61, 79];
            const bodyPartsSet = new Set();
            dayMarkers.forEach((headerRow, dayIndex) => {
                const day = {
                    name: String(sheet.getCell(`B${headerRow}`).value || `DAY ${dayIndex + 1}`),
                    exercises: [],
                };
                // Read exercises (start 2 rows after header)
                for (let row = headerRow + 2; row < headerRow + 16; row++) {
                    const exerciseName = sheet.getCell(`C${row}`).value;
                    if (!exerciseName)
                        continue;
                    const setsCount = Number(sheet.getCell(`D${row}`).value) || 3;
                    const repsValue = sheet.getCell(`E${row}`).value;
                    const reps = this.parseReps(String(repsValue || '8-12'), setsCount);
                    const exercise = {
                        name: String(exerciseName),
                        exerciseId: `exercise_${dayIndex}_${row}`,
                        bodyParts: [],
                        minutes: 0,
                        seconds: 0,
                        sets: reps.map((rep) => ({
                            reps: rep,
                            rir: 2,
                            weight: 0,
                        })),
                    };
                    // Check for body parts in notes
                    const notes = sheet.getCell(`K${row}`).value;
                    if (notes) {
                        const parts = String(notes)
                            .split(',')
                            .map((p) => p.trim());
                        exercise.bodyParts = parts;
                        parts.forEach((p) => bodyPartsSet.add(p));
                    }
                    // Check for video link
                    const videoCell = sheet.getCell(`L${row}`);
                    if (videoCell.hyperlink) {
                        exercise.videoUrl = videoCell.hyperlink;
                    }
                    day.exercises.push(exercise);
                }
                if (day.exercises.length > 0) {
                    trainingPlan.days.push(day);
                }
            });
            trainingPlan.bodyParts = Array.from(bodyPartsSet);
            return trainingPlan;
        });
    }
    /**
     * Parse reps string into array of strings
     * Preserves ranges like "8-12" as-is for each set
     */
    parseReps(repsStr, setCount) {
        // Handle formats like "8 / 10 / 12" - different reps per set
        if (repsStr.includes('/')) {
            return repsStr.split('/').map((r) => r.trim());
        }
        // For ranges like "8-12" or single values like "10", use same value for all sets
        return Array(setCount).fill(repsStr.trim());
    }
}
exports.TrainingPlanExcelService = TrainingPlanExcelService;
const excelService = new TrainingPlanExcelService();
exports.default = excelService;
