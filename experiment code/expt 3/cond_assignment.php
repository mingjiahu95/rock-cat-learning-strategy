

<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// initialize assignment log file
$assignment_log_filepath = './data/assignment_log.json';
$stim_filename_prefix =  './data/stim_files/stimInfo_';
parse_str(file_get_contents("php://input"), $_POST);

if (isset($_POST['ACTION'])) {
    $PID = $_POST['PROLIFIC_PID'];
    if ($_POST['ACTION'] === "fetch"){

        if (file_exists($assignment_log_filepath)) {
            $assignment_log = json_decode(file_get_contents($assignment_log_filepath), true);
        } else {
           $assignment_log = [
               'PIndex' => 1,
               'PID' => '',
               'StimFile' => $stim_filename_prefix. 1 . '.json',
               'CondCycleIndex' => 1,
               'CondIndex' => 0,
               'assignments' => [],
               'quit_assignments' => []
            ]; 
        }
           
       if (!empty($assignment_log["quit_assignments"])){
           $assignment_quit = array_shift($assignment_log["quit_assignments"]);
           $assignment = [
               'PIndex' => $assignment_quit['PIndex'],//make replacement subject have the same PIndex 
               'PID' => $PID, 
               'Stim' => $assignment_quit['Stim'],
               'Cond' => $assignment_quit['Cond']
           ];
        } else {
           $cond_cycle = [1, 2, 3, 3, 4, 4];
           $assignment = [
               'PIndex' => 'P'. $assignment_log['PIndex'],
               'PID' => $PID, 
               'Stim' => $assignment_log['StimFile'],
               'Cond' => $cond_cycle[$assignment_log['CondIndex']]
           ];
           //increment log variables for next subject
           $assignment_log['PIndex']++;
           $assignment_log['PID'] = $assignment['PID'];
           $assignment_log['CondIndex']++;
        
          //update the stim file and cond indices for the new cycle
          if ($assignment_log['CondIndex'] === count($cond_cycle)) {
              $assignment_log['CondIndex'] = 0;
              $assignment_log['CondCycleIndex']++;
              $assignment_log['StimFile'] = $stim_filename_prefix. $assignment_log['CondCycleIndex'] . '.json';
            }
        }   
       $assignment_log['assignments'][] = $assignment; 
       file_put_contents($assignment_log_filepath, json_encode($assignment_log));


       $data_sent = json_decode(file_get_contents($assignment['Stim']),true);
       $data_sent['cond'] = $assignment['Cond'];
       header('Content-Type: application/json');
       echo json_encode($data_sent);
        
    } else if ($_POST['ACTION'] === "quit") {
        $assignment_log = json_decode(file_get_contents($assignment_log_filepath), true);
    // find the corresponding subject assignment by PID
        foreach ($assignment_log['assignments'] as $assignment_subj) {
            if ($assignment_subj['PID'] === $PID) {
                $stimFile_subj = $assignment_subj['Stim'];
                $cond_subj = $assignment_subj['Cond'];
                $Pindex_subj = $assignment_subj['PIndex'];
            break; 
            }
        }
        $assignment = [
            'PIndex' => $Pindex_subj,
            'PID' => $PID, 
            'Stim' => $stimFile_subj,
            'Cond' => $cond_subj
        ];
        $assignment_log["quit_assignments"][] = $assignment;
        file_put_contents($assignment_log_filepath, json_encode($assignment_log));
    }
    exit();

} 
?>

