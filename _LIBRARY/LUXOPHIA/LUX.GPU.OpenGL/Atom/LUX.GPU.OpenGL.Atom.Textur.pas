unit LUX.GPU.OpenGL.Atom.Textur;

interface //#################################################################### ■

uses Winapi.OpenGL, Winapi.OpenGLext,
     LUX, LUX.GPU.OpenGL.Atom;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLTextur

     IGLTextur = interface( IGLAtomer )
     ['{E2F97606-18B0-4E45-88D2-ABE16446AD6F}']
       ///// アクセス
       function GetKind :GLenum;
       procedure SetKind( const Kind_:GLenum );
       function GetTexelF :GLenum;
       procedure SetTexelF( const TexelF_:GLenum );
       function GetPixelF :GLenum;
       procedure SetPixelF( const PixelF_:GLenum );
       function GetPixelT :GLenum;
       procedure SetPixelT( const PixelT_:GLenum );
       ///// プロパティ
       property Kind   :GLenum read GetKind   write SetKind  ;
       property TexelF :GLenum read GetTexelF write SetTexelF;
       property PixelF :GLenum read GetPixelF write SetPixelF;
       property PixelT :GLenum read GetPixelT write SetPixelT;
       /////メソッド
       procedure Bind;
       procedure Unbind;
       procedure Use( const BindI_:GLuint );
       procedure Unuse( const BindI_:GLuint );
       procedure UseComput( const BindI_:GLuint );
       procedure UnuseComput( const BindI_:GLuint );
       procedure SendData;
       procedure ReceData;
       procedure SendPixBuf;
       procedure RecePixBuf;
     end;

     //-------------------------------------------------------------------------

     TGLTextur = class( TGLAtomer, IGLTextur )
     private
     protected
       _Kind   :GLenum;
       _TexelF :GLenum;
       _PixelF :GLenum;
       _PixelT :GLenum;
       ///// アクセス
       function GetKind :GLenum;
       procedure SetKind( const Kind_:GLenum );
       function GetTexelF :GLenum;
       procedure SetTexelF( const TexelF_:GLenum ); virtual;
       function GetPixelF :GLenum;
       procedure SetPixelF( const PixelF_:GLenum );
       function GetPixelT :GLenum;
       procedure SetPixelT( const PixelT_:GLenum );
     public
       constructor Create( const Kind_:GLenum );
       destructor Destroy; override;
       ///// プロパティ
       property Kind   :GLenum read GetKind   write SetKind  ;
       property TexelF :GLenum read GetTexelF write SetTexelF;
       property PixelF :GLenum read GetPixelF write SetPixelF;
       property PixelT :GLenum read GetPixelT write SetPixelT;
       ///// メソッド
       procedure Bind;
       procedure Unbind;
       procedure Use( const BindI_:GLuint ); virtual;
       procedure Unuse( const BindI_:GLuint ); virtual;
       procedure UseComput( const BindI_:GLuint );
       procedure UnuseComput( const BindI_:GLuint );
       procedure SendData; virtual; abstract;
       procedure ReceData; virtual; abstract;
       procedure SendPixBuf; virtual; abstract;
       procedure RecePixBuf;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TGLTextur

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TGLTextur.GetKind :GLenum;
begin
     Result := _Kind;
end;

procedure TGLTextur.SetKind( const Kind_:GLenum );
begin
     _Kind := Kind_;
end;

function TGLTextur.GetTexelF :GLenum;
begin
     Result := _TexelF;
end;

procedure TGLTextur.SetTexelF( const TexelF_:GLenum );
begin
     _TexelF := TexelF_;
end;

function TGLTextur.GetPixelF :GLenum;
begin
     Result := _PixelF;
end;

procedure TGLTextur.SetPixelF( const PixelF_:GLenum );
begin
     _PixelF := PixelF_;
end;

function TGLTextur.GetPixelT :GLenum;
begin
     Result := _PixelT;
end;

procedure TGLTextur.SetPixelT( const PixelT_:GLenum );
begin
     _PixelT := PixelT_;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TGLTextur.Create( const Kind_:GLenum );
begin
     inherited Create;

     glGenTextures( 1, @_ID );

     _Kind := Kind_;

     Bind;
       glTexParameteri( _Kind, GL_TEXTURE_MAX_LEVEL, 0 );
     Unbind;
end;

destructor TGLTextur.Destroy;
begin
     glDeleteTextures( 1, @_ID );

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TGLTextur.Bind;
begin
     glBindTexture( _Kind, _ID );
end;

procedure TGLTextur.Unbind;
begin
     glBindTexture( _Kind, 0 );
end;

//------------------------------------------------------------------------------

procedure TGLTextur.Use( const BindI_:GLuint );
begin
     glActiveTexture( GL_TEXTURE0 + BindI_ );

       Bind;

     glActiveTexture( GL_TEXTURE0 );
end;

procedure TGLTextur.Unuse( const BindI_:GLuint );
begin
     glActiveTexture( GL_TEXTURE0 + BindI_ );

       Unbind;

     glActiveTexture( GL_TEXTURE0 );
end;

//------------------------------------------------------------------------------

procedure TGLTextur.UseComput( const BindI_:GLuint );
begin
     glBindImageTexture( BindI_, ID, 0, GL_FALSE, 0, GL_READ_WRITE, _TexelF );
end;

procedure TGLTextur.UnuseComput( const BindI_:GLuint );
begin
     glBindImageTexture( BindI_, 0, 0, GL_FALSE, 0, GL_READ_WRITE, _TexelF );
end;

//------------------------------------------------------------------------------

procedure TGLTextur.RecePixBuf;
begin
     glGetTexImage( _Kind, 0, _PixelF, _PixelT, nil );
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■