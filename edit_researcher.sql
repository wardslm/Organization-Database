if($_SERVER["REQUEST_METHOD"] == "POST")
{
echo "Post request submittd !!";
$user_privilege = check_user_type($_POST);
$country_id = $_POST["country_id"];
$first_name = $_POST["first_name"];
$last_name = $_POST["last_name"];
$email = $_POST["email"];
$phone = $_POST["phone"];
$org_name = "";
if ($_POST["org_name"] == Null){
$org_name = "N/A";
}else {
$org_name = $_POST["org_name"];
}
$date_of_birth = $_POST["date_of_birth"];
$user_name = $_POST["first_name"] . "_" . $_POST["last_name"]. "_" . $user_privilege;
$user_password = "c19pswd";
#input values
$con->query("SET @country_id='".$country_id."'");
$con->query("SET @first_name='".$first_name."'");
$con->query("SET @last_name='".$last_name."'");
$con->query("SET @email='".$email."'");
$con->query("SET @phone='".$phone."'");
$con->query("SET @org_name='".$org_name."'");
$con->query("SET @date_of_birth='".$date_of_birth."'");
$con->query("SET @user_name='".$user_name."'");
$con->query("SET @user_password='".$user_password."'");
$con->query("SET @user_privilege='".$user_privilege."'");
$con->query("DROP PROCEDURE IF EXISTS addNewUserFixed");
$con->query("DROP PROCEDURE IF EXISTS getUserId");
$con->query("DROP PROCEDURE IF EXISTS checkUserName");
$con->query(get_user_id());
$con->query(check_user_name());
$con->query(add_new_user());
$sql = "CALL addNewUserFixed (@country_id, @first_name, @last_name, @email, @phone,
@org_name, @date_of_birth, @user_name, @user_password, @user_privilege);";
$con->multi_query ($sql) OR DIE (mysqli_error($con));
while (mysqli_more_results($con)) {
if ($result = mysqli_store_result($con)) {
while ($row = mysqli_fetch_assoc($result)) {
// i.e.: DBTableFieldName="userID"
// echo "row = ".$row["DBTableFieldName"]."<br />";
// ....
echo "Looks ok!";
}
mysqli_free_result($result);
}
mysqli_next_result($con);
}
}
function get_user_id(){
return
'CREATE PROCEDURE getUserId(
IN c_id int,
IN first_name varchar(255),
IN last_name varchar(255),
IN email varchar(255),
IN phone varchar(255),
IN org_name varchar(255),
IN date_of_birth varchar(255),
OUT user_id int
)
BEGIN
select u.user_id into user_id
from Users as u
where u.country_id = c_id
and u.first_name = first_name
and u.last_name = last_name
and u.email = email
and u.phone = phone
and u.date_of_birth = date_of_birth;
END';
}
function check_user_name(){
return
'CREATE PROCEDURE checkUserName(
IN u_name varchar(255),
OUT name_unique bool
)
BEGIN
if binary u_name = any
(
select user_name from Admins
union
select user_name from Researchers
union
select user_name from RegUsers
union
select user_name from OrgDelegates
)
then
set name_unique := 0;
else
set name_unique :=1;
end if;
END';
}
function add_new_user(){
return 'CREATE PROCEDURE addNewUserFixed(
IN c_id int,
IN first_name varchar(255),
IN last_name varchar(255),
IN email varchar(255),
IN phone varchar(255),
IN org_name varchar(255),
IN date_of_birth varchar(255),
IN user_name varchar(255),
IN user_password varchar(255),
IN user_privilege varcharacter(255)
)
BEGIN
declare is_unique_name bool default 1;
declare user_id int;
if c_id = any (
select country_id
from Countries
)
then
call checkUserName(user_name, @name_unique);
select @name_unique into is_unique_name ;
if is_unique_name
then
call getUserId(c_id, first_name, last_name, email, phone, org_name, date_of_birth,
@u_id);
select @u_id into user_id;
if user_id is Null
then
insert into Users (country_id, first_name, last_name, email, phone, org_name,
date_of_birth)
value (c_id, first_name, last_name, email, phone, org_name, date_of_birth);
call getUserId(c_id, first_name, last_name, email, phone, org_name, date_of_birth,
@u_id);
select @u_id into user_id;
end if;
#creating special privileges
if user_privilege = "administrator"
then
insert into Admins (user_id, user_name, user_password)
value (user_id, user_name, user_password);
elseif user_privilege = "researcher"
then
insert into Researchers (user_id, user_name, user_password)
value (user_id, user_name, user_password);
elseif user_privilege = "org_deligate"
then
insert into OrgDelegates (user_id, user_name, user_password)
value (user_id, user_name, user_password);
else
insert into RegUsers (user_id, user_name, user_password)
value (user_id, user_name, user_password);
end if;
end if;
end if;
END; ';
}
#delete
<?php
session_start();
require '../dbMysqli.php';
$u_id = $_GET["user_id"]; # user_id of the selected user
$admin_id = $_SESSION["user_id"]; # save user_id in the session when user logged in
if($_SERVER["REQUEST_METHOD"] == "GET")
{
#input values
$con->query("SET @u_id='".$u_id."'");
$con->query("SET @admin_id='".$admin_id."'");
$con->query("SET @action_type='delete'");
$con->query("DROP PROCEDURE IF EXISTS logsAdmin");
$con->query(delete_user());
$sql = "CALL logsAdmin (@u_id, @admin_id, @action_type);";
$con->multi_query ($sql) OR DIE (mysqli_error($con));
while (mysqli_more_results($con)) {
if ($result = mysqli_store_result($con)) {
while ($row = mysqli_fetch_assoc($result)) {
// i.e.: DBTableFieldName="userID"
// echo "row = ".$row["DBTableFieldName"]."<br />";
// ....
}
mysqli_free_result($result);
}
mysqli_next_result($con);
}
header("Location: index.php");
}
function delete_user(){
return 'CREATE PROCEDURE logsAdmin(
IN u_id int,
IN admin_id int,
IN action_type varcharacter(255)
)
BEGIN
if action_type = "delete"
then
UPDATE fuc353_1.Users SET is_active = 0 where user_id = u_id;
insert into fuc353_1.AdminLogs (user_id, admin_id, action_type)
value
(u_id, admin_id, action_type);
end if;
END ';
}
?>
#edit
if($_SERVER["REQUEST_METHOD"] == "GET")
{
$user_id = $_GET["user_id"];
$user = fill_user_info($con, $user_id);
}elseif ($_SERVER["REQUEST_METHOD"] == "POST")
{
$user_id = $_POST["user_id"];
$stmt = $con->prepare("UPDATE fuc353_1.Users SET first_name = :first_name,
last_name = :last_name,
country_id = :country_id,
email = :email,
phone = :phone
WHERE user_id = :user_id");
$stmt->bindParam(":first_name", $_POST["first_name"]);
$stmt->bindParam(":last_name", $_POST["last_name"]);
$stmt->bindParam(":country_id", $_POST["country_id"]); #TODO: check if country_id is not in the
system
$stmt->bindParam(":email", $_POST["email"]);
$stmt->bindParam(":phone", $_POST["phone"]);
$stmt->bindParam(":user_id", $_POST["user_id"]);
try {
if($stmt->execute()){
echo 'successfully updated the user info';
// fill_user_info($con, $user_id);
}else{
echo 'failed to update the user info';
// fill_user_info($con, $user_id);
}
}catch(Exception $e){
echo 'Something went wrong, Check the input and try it again. ', "<br />";
echo 'Caught exception: ', $e->getMessage(), "<br />";
echo '<a href="./activeUsers.php">Back to active users</a>';
}
}
function fill_user_info($con, $user_id){
$query = 'select user_id, first_name, last_name, country_id, email, phone
from fuc353_1.Users
where user_id = :user_id;';
$stmt = $con->prepare($query);
$stmt->bindParam(":user_id", $user_id);
if ($stmt->execute()){
echo 'successful';
$user = $stmt->fetch(PDO::FETCH_ASSOC);
echo 'The result found is: ' . $user["user_id"];
return $user;
}else {
echo 'something went wrong';
return Null;
}
}
