{ ThreadedTimer found in "Delphi Developer's Journal" of May 1996 Vol. 2 No. 5 }

unit ThdTimer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TThreadedTimer = class;

  TTimerThread = class(TThread)
    OwnerTimer: TThreadedTimer;
    procedure Execute; override;
  end;

  TThreadedTimer = class(TComponent)
  private
    FEnabled: boolean;
    FInterval: word;
    FOnTimer: TNotifyEvent;
    FTimerThread: TTimerThread;
    FThreadPriority: TThreadPriority;
  protected
    procedure UpdateTimer;
    procedure SetEnabled(value: boolean);
    procedure SetInterval(value: word);
    procedure SetOnTimer(value: TNotifyEvent);
    procedure SetThreadPriority(value: TThreadPriority);
    procedure Timer; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: boolean read FEnabled write SetEnabled default true;
    property Interval: word read FInterval write SetInterval default 1000;
    property Priority: TThreadPriority read FThreadPriority write SetThreadPriority default tpNormal;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
  end;

procedure Register;

implementation

procedure TTimerThread.Execute;
begin
  Priority := OwnerTimer.FThreadPriority;
  repeat
    SleepEx(OwnerTimer.FInterval, False);
    Synchronize(OwnerTimer.Timer);
  until Terminated;
end;

constructor TThreadedTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FInterval := 1000;
  FThreadPriority := tpNormal;
  FTimerThread := TTimerThread.Create(False);
  FTimerThread.OwnerTimer := Self;
end;

destructor TThreadedTimer.Destroy;
begin
  FEnabled := False;
  UpdateTimer;
  FTimerThread.Free;
  inherited Destroy;
end;

procedure TThreadedTimer.UpdateTimer;
begin
  if not FTimerThread.Suspended then FTimerThread.Suspend;
  if (FInterval <> 0) and FEnabled then
     if FTimerThread.Suspended then FTimerThread.Resume;
end;

procedure TThreadedTimer.SetEnabled(value: boolean);
begin
  if value <> FEnabled then
  begin
    FEnabled := value;
    UpdateTimer;
  end;
end;

procedure TThreadedTimer.SetInterval(value: Word);
begin
  if value <> FInterval then
  begin
    FInterval := value;
    UpdateTimer;
  end;
end;

procedure TThreadedTimer.SetOnTimer(value: TNotifyEvent);
begin
  FOnTimer := value;
  UpdateTimer;
end;

procedure TThreadedTimer.SetThreadPriority(value: TThreadPriority);
begin
  if value <> FThreadPriority then
  begin
    FThreadPriority := value;
    UpdateTimer;
  end;
end;

procedure TThreadedTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;

procedure Register;
begin
  RegisterComponents('!', [TThreadedTimer]);
end;

end.
