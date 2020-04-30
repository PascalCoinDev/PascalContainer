unit CodaMinaAVLTree;

interface

uses
  Classes, SysUtils;

type
  
  generic TCodaMinaAVLTree<T> = class
  type
    Comp_func = function (a, b: T): Integer;
    PAVLNode = ^TAVLNode;
    TAVLNode = record
      Balance: Integer;
      Data: T;
      Left: PAVLNode;
      Parent: PAVLNode;
      Right: PAVLNode;
    end;
  private
    FCount: Integer;
    Root: PAVLNode;
    cmp: Comp_func;
    freehead,freetail:PAVLNode;
    procedure BalanceAfterDelete(ANode: PAVLNode);
    procedure BalanceAfterInsert(ANode: PAVLNode);
    function FindInsertPos(Data: T): PAVLNode;
    procedure AddNode(ANode: PAVLNode);
    procedure freeNode(x: PAVLNode);
    function NewNode():PAVLNode;
    procedure printTreeNode(n:PAVLNode; offs:integer);
    procedure DeleteNode(ANode: PAVLNode);
    function FindPrecessor(ANode: PAVLNode): PAVLNode;
    function FindSuccessor(ANode: PAVLNode): PAVLNode;
    procedure Delete(ANode: PAVLNode);
  public
    constructor Create(c: Comp_func);
    destructor Destroy; override;
    function Add(Data: T): PAVLNode;
    procedure Clear;
    function Find(Data: T): PAVLNode;
    procedure Remove(Data: T);
    procedure printTree();
    property Count: Integer read FCount;
  end;

implementation

constructor TCodaMinaAVLTree.Create(c: Comp_func);
begin
  inherited Create;
  cmp := c;
  FCount := 0;
  Root := nil;
  freehead:=nil;
  freetail:=nil;
end;

destructor TCodaMinaAVLTree.Destroy;
begin
  Clear;
  inherited Destroy;
end;
procedure TCodaMinaAVLTree.freeNode(x: PAVLNode);
begin
  x^.parent:=nil;
  x^.left:=nil;
  x^.Balance:=0;
  x^.Right:=nil;
  if freehead=nil then
  begin
    freehead:=x;
  end
  else
  begin
    freetail^.right:=x;
  end;
  freetail:=x;
end;
function TCodaMinaAVLTree.NewNode():PAVLNode;
begin
  if freehead=nil then
  begin
    result:=new(PAVLNode);
    result^.Balance:=0;
    result^.Left:=nil;
    result^.Right:=nil;
    result^.Parent:=nil;
  end
  else
  begin
    result:=freehead;
    freehead:=freehead^.right;
  end;
end;
function TCodaMinaAVLTree.Add(Data: T): PAVLNode;
begin
  Result := NewNode();
  Result^.Data := Data;
  AddNode(Result);
end;

procedure TCodaMinaAVLTree.AddNode(ANode: PAVLNode);
var
  InsertPos: PAVLNode;
  InsertComp: Integer;

  // add a node. If there are already nodes with the same value it will be
  // inserted rightmost

begin
  ANode^.Left := nil;
  ANode^.Right := nil;
  inc(FCount);
  if Root <> nil then
  begin
    InsertPos := FindInsertPos(ANode^.Data);
    InsertComp := cmp(ANode^.Data, InsertPos^.Data);
    ANode^.Parent := InsertPos;
    if InsertComp < 0 then
    begin
      // insert to the left
      InsertPos^.Left := ANode;
    end
    else
    begin
      // insert to the right
      InsertPos^.Right := ANode;
    end;
    BalanceAfterInsert(ANode);
  end
  else
  begin
    Root := ANode;
    ANode^.Parent := nil;
  end;
end;

procedure TCodaMinaAVLTree.BalanceAfterDelete(ANode: PAVLNode);
var
  OldParent, OldRight, OldRightLeft, OldLeft, OldLeftRight, OldRightLeftLeft,
    OldRightLeftRight, OldLeftRightLeft, OldLeftRightRight: PAVLNode;
begin
  if (ANode = nil) then
    exit;
  if ((ANode^.Balance = +1) or (ANode^.Balance = -1)) then
    exit;
  OldParent := ANode^.Parent;
  if (ANode^.Balance = 0) then
  begin
    // Treeheight has decreased by one
    if (OldParent <> nil) then
    begin
      if (OldParent^.Left = ANode) then
        Inc(OldParent^.Balance)
      else
        Dec(OldParent^.Balance);
      BalanceAfterDelete(OldParent);
    end;
    exit;
  end;
  if (ANode^.Balance = +2) then
  begin
    // Node is overweighted to the right
    OldRight := ANode^.Right;
    if (OldRight^.Balance >= 0) then
    begin
      // OldRight^.Balance=={0 or -1}
      // rotate left
      OldRightLeft := OldRight^.Left;
      if (OldParent <> nil) then
      begin
        if (OldParent^.Left = ANode) then
          OldParent^.Left := OldRight
        else
          OldParent^.Right := OldRight;
      end
      else
        Root := OldRight;
      ANode^.Parent := OldRight;
      ANode^.Right := OldRightLeft;
      OldRight^.Parent := OldParent;
      OldRight^.Left := ANode;
      if (OldRightLeft <> nil) then
        OldRightLeft^.Parent := ANode;
      ANode^.Balance := (1 - OldRight^.Balance);
      Dec(OldRight^.Balance);
      BalanceAfterDelete(OldRight);
    end
    else
    begin
      // OldRight^.Balance=-1
      // double rotate right left
      OldRightLeft := OldRight^.Left;
      OldRightLeftLeft := OldRightLeft^.Left;
      OldRightLeftRight := OldRightLeft^.Right;
      if (OldParent <> nil) then
      begin
        if (OldParent^.Left = ANode) then
          OldParent^.Left := OldRightLeft
        else
          OldParent^.Right := OldRightLeft;
      end
      else
        Root := OldRightLeft;
      ANode^.Parent := OldRightLeft;
      ANode^.Right := OldRightLeftLeft;
      OldRight^.Parent := OldRightLeft;
      OldRight^.Left := OldRightLeftRight;
      OldRightLeft^.Parent := OldParent;
      OldRightLeft^.Left := ANode;
      OldRightLeft^.Right := OldRight;
      if (OldRightLeftLeft <> nil) then
        OldRightLeftLeft^.Parent := ANode;
      if (OldRightLeftRight <> nil) then
        OldRightLeftRight^.Parent := OldRight;
      if (OldRightLeft^.Balance <= 0) then
        ANode^.Balance := 0
      else
        ANode^.Balance := -1;
      if (OldRightLeft^.Balance >= 0) then
        OldRight^.Balance := 0
      else
        OldRight^.Balance := +1;
      OldRightLeft^.Balance := 0;
      BalanceAfterDelete(OldRightLeft);
    end;
  end
  else
  begin
    // Node.Balance=-2
    // Node is overweighted to the left
    OldLeft := ANode^.Left;
    if (OldLeft^.Balance <= 0) then
    begin
      // rotate right
      OldLeftRight := OldLeft^.Right;
      if (OldParent <> nil) then
      begin
        if (OldParent^.Left = ANode) then
          OldParent^.Left := OldLeft
        else
          OldParent^.Right := OldLeft;
      end
      else
        Root := OldLeft;
      ANode^.Parent := OldLeft;
      ANode^.Left := OldLeftRight;
      OldLeft^.Parent := OldParent;
      OldLeft^.Right := ANode;
      if (OldLeftRight <> nil) then
        OldLeftRight^.Parent := ANode;
      ANode^.Balance := (-1 - OldLeft^.Balance);
      Inc(OldLeft^.Balance);
      BalanceAfterDelete(OldLeft);
    end
    else
    begin
      // OldLeft^.Balance = 1
      // double rotate left right
      OldLeftRight := OldLeft^.Right;
      OldLeftRightLeft := OldLeftRight^.Left;
      OldLeftRightRight := OldLeftRight^.Right;
      if (OldParent <> nil) then
      begin
        if (OldParent^.Left = ANode) then
          OldParent^.Left := OldLeftRight
        else
          OldParent^.Right := OldLeftRight;
      end
      else
        Root := OldLeftRight;
      ANode^.Parent := OldLeftRight;
      ANode^.Left := OldLeftRightRight;
      OldLeft^.Parent := OldLeftRight;
      OldLeft^.Right := OldLeftRightLeft;
      OldLeftRight^.Parent := OldParent;
      OldLeftRight^.Left := OldLeft;
      OldLeftRight^.Right := ANode;
      if (OldLeftRightLeft <> nil) then
        OldLeftRightLeft^.Parent := OldLeft;
      if (OldLeftRightRight <> nil) then
        OldLeftRightRight^.Parent := ANode;
      if (OldLeftRight^.Balance >= 0) then
        ANode^.Balance := 0
      else
        ANode^.Balance := +1;
      if (OldLeftRight^.Balance <= 0) then
        OldLeft^.Balance := 0
      else
        OldLeft^.Balance := -1;
      OldLeftRight^.Balance := 0;
      BalanceAfterDelete(OldLeftRight);
    end;
  end;
end;

procedure TCodaMinaAVLTree.BalanceAfterInsert(ANode: PAVLNode);
var
  OldParent, OldParentParent, OldRight, OldRightLeft, OldRightRight, OldLeft,
    OldLeftLeft, OldLeftRight: PAVLNode;
begin
  OldParent := ANode^.Parent;
  if (OldParent = nil) then
    exit;
  if (OldParent^.Left = ANode) then
  begin
    // Node is left son
    dec(OldParent^.Balance);
    if (OldParent^.Balance = 0) then
      exit;
    if (OldParent^.Balance = -1) then
    begin
      BalanceAfterInsert(OldParent);
      exit;
    end;
    // OldParent^.Balance=-2
    if (ANode^.Balance = -1) then
    begin
      // rotate
      OldRight := ANode^.Right;
      OldParentParent := OldParent^.Parent;
      if (OldParentParent <> nil) then
      begin
        // OldParent has GrandParent. GrandParent gets new child
        if (OldParentParent^.Left = OldParent) then
          OldParentParent^.Left := ANode
        else
          OldParentParent^.Right := ANode;
      end
      else
      begin
        // OldParent was root node. New root node
        Root := ANode;
      end;
      ANode^.Parent := OldParentParent;
      ANode^.Right := OldParent;
      OldParent^.Parent := ANode;
      OldParent^.Left := OldRight;
      if (OldRight <> nil) then
        OldRight^.Parent := OldParent;
      ANode^.Balance := 0;
      OldParent^.Balance := 0;
    end
    else
    begin
      // Node.Balance = +1
      // double rotate
      OldParentParent := OldParent^.Parent;
      OldRight := ANode^.Right;
      OldRightLeft := OldRight^.Left;
      OldRightRight := OldRight^.Right;
      if (OldParentParent <> nil) then
      begin
        // OldParent has GrandParent. GrandParent gets new child
        if (OldParentParent^.Left = OldParent) then
          OldParentParent^.Left := OldRight
        else
          OldParentParent^.Right := OldRight;
      end
      else
      begin
        // OldParent was root node. new root node
        Root := OldRight;
      end;
      OldRight^.Parent := OldParentParent;
      OldRight^.Left := ANode;
      OldRight^.Right := OldParent;
      ANode^.Parent := OldRight;
      ANode^.Right := OldRightLeft;
      OldParent^.Parent := OldRight;
      OldParent^.Left := OldRightRight;
      if (OldRightLeft <> nil) then
        OldRightLeft^.Parent := ANode;
      if (OldRightRight <> nil) then
        OldRightRight^.Parent := OldParent;
      if (OldRight^.Balance <= 0) then
        ANode^.Balance := 0
      else
        ANode^.Balance := -1;
      if (OldRight^.Balance = -1) then
        OldParent^.Balance := 1
      else
        OldParent^.Balance := 0;
      OldRight^.Balance := 0;
    end;
  end
  else
  begin
    // Node is right son
    Inc(OldParent^.Balance);
    if (OldParent^.Balance = 0) then
      exit;
    if (OldParent^.Balance = +1) then
    begin
      BalanceAfterInsert(OldParent);
      exit;
    end;
    // OldParent^.Balance = +2
    if (ANode^.Balance = +1) then
    begin
      // rotate
      OldLeft := ANode^.Left;
      OldParentParent := OldParent^.Parent;
      if (OldParentParent <> nil) then
      begin
        // Parent has GrandParent . GrandParent gets new child
        if (OldParentParent^.Left = OldParent) then
          OldParentParent^.Left := ANode
        else
          OldParentParent^.Right := ANode;
      end
      else
      begin
        // OldParent was root node . new root node
        Root := ANode;
      end;
      ANode^.Parent := OldParentParent;
      ANode^.Left := OldParent;
      OldParent^.Parent := ANode;
      OldParent^.Right := OldLeft;
      if (OldLeft <> nil) then
        OldLeft^.Parent := OldParent;
      ANode^.Balance := 0;
      OldParent^.Balance := 0;
    end
    else
    begin
      // Node.Balance = -1
      // double rotate
      OldLeft := ANode^.Left;
      OldParentParent := OldParent^.Parent;
      OldLeftLeft := OldLeft^.Left;
      OldLeftRight := OldLeft^.Right;
      if (OldParentParent <> nil) then
      begin
        // OldParent has GrandParent . GrandParent gets new child
        if (OldParentParent^.Left = OldParent) then
          OldParentParent^.Left := OldLeft
        else
          OldParentParent^.Right := OldLeft;
      end
      else
      begin
        // OldParent was root node . new root node
        Root := OldLeft;
      end;
      OldLeft^.Parent := OldParentParent;
      OldLeft^.Left := OldParent;
      OldLeft^.Right := ANode;
      ANode^.Parent := OldLeft;
      ANode^.Left := OldLeftRight;
      OldParent^.Parent := OldLeft;
      OldParent^.Right := OldLeftLeft;
      if (OldLeftLeft <> nil) then
        OldLeftLeft^.Parent := OldParent;
      if (OldLeftRight <> nil) then
        OldLeftRight^.Parent := ANode;
      if (OldLeft^.Balance >= 0) then
        ANode^.Balance := 0
      else
        ANode^.Balance := +1;
      if (OldLeft^.Balance = +1) then
        OldParent^.Balance := -1
      else
        OldParent^.Balance := 0;
      OldLeft^.Balance := 0;
    end;
  end;
end;

procedure TCodaMinaAVLTree.Clear;
  // Clear
begin
  DeleteNode(Root);
  Root := nil;
  FCount := 0;
end;
procedure TCodaMinaAVLTree.DeleteNode(ANode: PAVLNode);
begin
  if ANode <> nil then
  begin
    if ANode^.Left <> nil then
      DeleteNode(ANode^.Left);
    if ANode^.Right <> nil then
      DeleteNode(ANode^.Right);
  end;
  freeNode(ANode);
end;


procedure TCodaMinaAVLTree.Delete(ANode: PAVLNode);
var
  OldParent, OldLeft, OldRight, Successor, OldSuccParent, OldSuccLeft,
    OldSuccRight: PAVLNode;
  OldBalance: Integer;
begin
  OldParent := ANode^.Parent;
  OldBalance := ANode^.Balance;
  ANode^.Parent := nil;
  ANode^.Balance := 0;
  if ((ANode^.Left = nil) and (ANode^.Right = nil)) then
  begin
    // Node is Leaf (no children)
    if (OldParent <> nil) then
    begin
      // Node has parent
      if (OldParent^.Left = ANode) then
      begin
        // Node is left Son of OldParent
        OldParent^.Left := nil;
        Inc(OldParent^.Balance);
      end
      else
      begin
        // Node is right Son of OldParent
        OldParent^.Right := nil;
        Dec(OldParent^.Balance);
      end;
      BalanceAfterDelete(OldParent);
    end
    else
    begin
      // Node is the only node of tree
      Root := nil;
    end;
    dec(FCount);
    FreeNode(ANode);
    exit;
  end;
  if (ANode^.Right = nil) then
  begin
    // Left is only son
    // and because DelNode is AVL, Right has no childrens
    // replace DelNode with Left
    OldLeft := ANode^.Left;
    ANode^.Left := nil;
    OldLeft^.Parent := OldParent;
    if (OldParent <> nil) then
    begin
      if (OldParent^.Left = ANode) then
      begin
        OldParent^.Left := OldLeft;
        Inc(OldParent^.Balance);
      end
      else
      begin
        OldParent^.Right := OldLeft;
        Dec(OldParent^.Balance);
      end;
      BalanceAfterDelete(OldParent);
    end
    else
    begin
      Root := OldLeft;
    end;
    dec(FCount);
    FreeNode(ANode);
    exit;
  end;
  if (ANode^.Left = nil) then
  begin
    // Right is only son
    // and because DelNode is AVL, Left has no childrens
    // replace DelNode with Right
    OldRight := ANode^.Right;
    ANode^.Right := nil;
    OldRight^.Parent := OldParent;
    if (OldParent <> nil) then
    begin
      if (OldParent^.Left = ANode) then
      begin
        OldParent^.Left := OldRight;
        Inc(OldParent^.Balance);
      end
      else
      begin
        OldParent^.Right := OldRight;
        Dec(OldParent^.Balance);
      end;
      BalanceAfterDelete(OldParent);
    end
    else
    begin
      Root := OldRight;
    end;
    dec(FCount);
    FreeNode(ANode);
    exit;
  end;
  // DelNode has both: Left and Right
  // Replace ANode with symmetric Successor
  Successor := FindSuccessor(ANode);
  OldLeft := ANode^.Left;
  OldRight := ANode^.Right;
  OldSuccParent := Successor^.Parent;
  OldSuccLeft := Successor^.Left;
  OldSuccRight := Successor^.Right;
  ANode^.Balance := Successor^.Balance;
  Successor^.Balance := OldBalance;
  if (OldSuccParent <> ANode) then
  begin
    // at least one node between ANode and Successor
    ANode^.Parent := Successor^.Parent;
    if (OldSuccParent^.Left = Successor) then
      OldSuccParent^.Left := ANode
    else
      OldSuccParent^.Right := ANode;
    Successor^.Right := OldRight;
    OldRight^.Parent := Successor;
  end
  else
  begin
    // Successor is right son of ANode
    ANode^.Parent := Successor;
    Successor^.Right := ANode;
  end;
  Successor^.Left := OldLeft;
  if OldLeft <> nil then
    OldLeft^.Parent := Successor;
  Successor^.Parent := OldParent;
  ANode^.Left := OldSuccLeft;
  if ANode^.Left <> nil then
    ANode^.Left^.Parent := ANode;
  ANode^.Right := OldSuccRight;
  if ANode^.Right <> nil then
    ANode^.Right^.Parent := ANode;
  if (OldParent <> nil) then
  begin
    if (OldParent^.Left = ANode) then
      OldParent^.Left := Successor
    else
      OldParent^.Right := Successor;
  end
  else
    Root := Successor;
  // delete Node as usual
  Delete(ANode);
end;

function TCodaMinaAVLTree.Find(Data: T): PAVLNode;
var
  Comp: Integer;
begin
  Result := Root;
  while (Result <> nil) do
  begin
    Comp := cmp(Data, Result^.Data);
    if Comp = 0 then
      exit;
    if Comp < 0 then
    begin
      Result := Result^.Left;
    end
    else
    begin
      Result := Result^.Right;
    end;
  end;
  result:=nil;
end;


function TCodaMinaAVLTree.FindInsertPos(Data: T): PAVLNode;
var
  Comp: Integer;
begin
  Result := Root;
  while (Result <> nil) do
  begin
    Comp := cmp(Data, Result^.Data);
    if Comp < 0 then
    begin
      if Result^.Left <> nil then
        Result := Result^.Left
      else
        exit;
    end
    else
    begin
      if Result^.Right <> nil then
        Result := Result^.Right
      else
        exit;
    end;
  end;
end;


function TCodaMinaAVLTree.FindPrecessor(ANode: PAVLNode): PAVLNode;
begin
  Result := ANode^.Left;
  if Result <> nil then
  begin
    while (Result^.Right <> nil) do
      Result := Result^.Right;
  end
  else
  begin
    Result := ANode;
    while (Result^.Parent <> nil) and (Result^.Parent^.Left = Result) do
      Result := Result^.Parent;
    Result := Result^.Parent;
  end;
end;


function TCodaMinaAVLTree.FindSuccessor(ANode: PAVLNode): PAVLNode;
begin
  Result := ANode^.Right;
  if Result <> nil then
  begin
    while (Result^.Left <> nil) do
      Result := Result^.Left;
  end
  else
  begin
    Result := ANode;
    while (Result^.Parent <> nil) and (Result^.Parent^.Right = Result) do
      Result := Result^.Parent;
    Result := Result^.Parent;
  end;
end;

procedure TCodaMinaAVLTree.Remove(Data: T);
var
  ANode: PAVLNode;
begin
  ANode := Find(Data);
  if ANode <> nil then
    Delete(ANode);
end;

procedure TCodaMinaAVLTree.printTreeNode(n:PAVLNode; offs:integer);
var
  i:integer;
begin
    for i := 0 to offs-1  do
      write(stdout,' ');
    
    if n=nil then
    begin
      writeln(stdout,'(nil)');
      exit;
    end;
    if offs=0 then
      write(stdout,'[*] ',integer(n),'=',n^.data,' Balance=',n^.Balance)
    else
    if (n^.Left = nil) and (n^.Right = nil) then
      write(stdout,'[L] ',integer(n),'=',n^.data,' Balance=',n^.Balance)
    else 
      write(stdout,'[I] ',integer(n),'=',n^.data,' Balance=',n^.Balance);

    writeln(stdout);
    for i := 0 to   offs  do
        write(stdout,' ');

    printTreeNode(n^.Left, offs + 1);
    for i := 0 to   offs  do
        write(stdout,' ');
    printTreeNode(n^.Right, offs + 1);
end;
procedure TCodaMinaAVLTree.printtree();
begin
  printTreeNode(root, 0);
end;
initialization

finalization

end.
