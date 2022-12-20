program Server.Delivery.Test;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  {$ENDIF }
  DUnitX.TestFramework,
  Controllers.Server.Delivery.Cliente.Test in 'Controllers.Server.Delivery.Cliente.Test.pas',
  Server.Delivery.Model.Cliente in '..\MODELS\Server.Delivery.Model.Cliente.pas',
  Server.Delivery.Model.Interfaces in '..\MODELS\Server.Delivery.Model.Interfaces.pas',
  Server.Delivery.Model.Produto in '..\MODELS\Server.Delivery.Model.Produto.pas',
  Server.Delivery.MySQL.Connection in '..\MODELS\Server.Delivery.MySQL.Connection.pas',
  Server.Delivery.SQLite.Connection in '..\MODELS\Server.Delivery.SQLite.Connection.pas',
  Server.Delivery.DTO in '..\DTO\Server.Delivery.DTO.pas',
  Controllers.Server.Delivery.Cliente.Route in '..\CONTROLLERS\Controllers.Server.Delivery.Cliente.Route.pas',
  Server.Delivery.Controller.Interfaces in '..\CONTROLLERS\Server.Delivery.Controller.Interfaces.pas',
  Server.Delivery.Controller in '..\CONTROLLERS\Server.Delivery.Controller.pas',
  Server.Delivery.Controller.Routes in '..\CONTROLLERS\Server.Delivery.Controller.Routes.pas',
  Controllers.Server.Delivery.Produtos.Test in 'Controllers.Server.Delivery.Produtos.Test.pas';
 {$IFNDEF TESTINSIGHT}

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger: ITestLogger;
{$ENDIF}

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.

