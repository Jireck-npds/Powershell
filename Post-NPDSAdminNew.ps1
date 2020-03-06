funtion Post-NPDSAdminNew{

$urlsite ="" # A remplir

$postParams = @{
  author='root';
  subject='Post with Powershell';
  topic='1';
  catid='1';
  ihome='1';
  members='0';
  hometext='Debut de text a mettre';
  op='PostStory';
  bodytext='le corps du tex'
  }
$Story = Invoke-WebRequest -Uri ("http://$urlsite/admin.php") -Method POST -Body $postParams -WebSession $admin
}
