

<?php
$input = file_get_contents('php://input');
$obj = json_decode($input, true);
$cond = $obj["condition"];
$file_ID = uniqid("subj-");
switch ($status) {
    case "completed":
        switch ($cond) {
            case 1:
                $folder_path = "./data/GEE/";
                break;
            case 2:
                $folder_path = "./data/GEA/";
                break;
            case 3:
                $folder_path = "./data/GCP/";
                break;
            case 4:
                $folder_path = "./data/CCP/";
                break;
        }
        break;
    case "incomplete":
        $folder_path = "./data/junk/";
        break;
}

$file_path = "{$folder_path}cond_{$cond}_subj_{$file_ID}" ;
file_put_contents("{$file_path}.csv", $obj["exptData"]);
file_put_contents("{$file_path}.json", $obj["stimData"]);
?>