<?php

if($_POST['submit']){
    $word = $_POST['word'];
    if(strlen($word) < 21){
	$output = shell_exec("./gohyphenfull patterns {$word}");
	echo "<pre>$output</pre>";
    }
}
?>


<form action="<?php echo $_SERVER['REQUEST_URI']?>" method="POST">
    <label class="control-label">word:</label>
    <input type="text" class="form-control" name="word" maxlength="20">
    <input type="submit" class="btn blue" value="Send" id="submit" name="submit"/>
</form>

