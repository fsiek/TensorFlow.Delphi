program TensorFlowDelphi;

{$WARN DUPLICATE_CTOR_DTOR OFF}

uses
  FastMM5,
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  EFastMM5Support,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  Vcl.Forms,
  untMain in 'untMain.pas' {frmMain},
  Tensorflow in 'src\Tensorflow.pas',
  Tensorflow.Utils in 'src\Tensorflow.Utils.pas',
  NumPy.NDArray in 'src\NumpPy\NumPy.NDArray.pas',
  Numpy.Axis in 'src\NumpPy\Numpy.Axis.pas',
  TensorFlow.Ops in 'src\Operation\TensorFlow.Ops.pas',
  TensorFlow.Variable in 'src\TensorFlow.Variable.pas',
  Complex in 'src\lib\Complex.pas',
  TensorFlow.DApi in 'src\Core\TensorFlow.DApi.pas',
  TensorFlow.DApiBase in 'src\Core\TensorFlow.DApiBase.pas',
  TF4D.Core.CApiEager in 'src\Core\TF4D.Core.CApiEager.pas',
  TensorFlow.Tensor in 'src\TensorFlow.Tensor.pas',
  TF4D.Core.CApi in 'src\Core\TF4D.Core.CApi.pas',
  Numpy in 'src\NumpPy\Numpy.pas',
  TensorFlow.OpDefLibrary in 'src\Operation\TensorFlow.OpDefLibrary.pas',
  TensorFlow.gen_math_ops in 'src\Operation\TensorFlow.gen_math_ops.pas',
  Tensorflow.gen_array_ops in 'src\Operation\Tensorflow.gen_array_ops.pas',
  Tensorflow.math_ops in 'src\Operation\Tensorflow.math_ops.pas',
  Tensorflow.array_ops in 'src\Operation\Tensorflow.array_ops.pas',
  Tensorflow.Gradient in 'src\Gradient\Tensorflow.Gradient.pas',
  TensorFlow.Slice in 'src\TensorFlow.Slice.pas',
  TensorFlow.String_ops in 'src\Operation\TensorFlow.String_ops.pas',
  TensorFlow.gen_state_ops in 'src\Operation\TensorFlow.gen_state_ops.pas',
  TensorFlow.gen_resource_variable_ops in 'src\Operation\TensorFlow.gen_resource_variable_ops.pas',
  TensorFlow.gen_control_flow_ops in 'src\Operation\TensorFlow.gen_control_flow_ops.pas',
  TensorFlow.control_flow_ops in 'src\Operation\TensorFlow.control_flow_ops.pas',
  TensorFlow.gen_sparse_ops in 'src\Operation\TensorFlow.gen_sparse_ops.pas',
  TensorFlow.resource_variable_ops in 'src\Operation\TensorFlow.resource_variable_ops.pas',
  Esempi in 'Esempi.pas',
  TensorFlow.gen_random_ops in 'src\Operation\TensorFlow.gen_random_ops.pas',
  TensorFlow.random_ops in 'src\Operation\TensorFlow.random_ops.pas',
  TensorFlow.clip_ops in 'src\Operation\TensorFlow.clip_ops.pas',
  Keras.Layer in 'src\Keras\Keras.Layer.pas',
  TensorFlow.gen_data_flow_ops in 'src\Operation\TensorFlow.gen_data_flow_ops.pas',
  TensorFlow.nn_ops in 'src\Operation\TensorFlow.nn_ops.pas',
  TensorFlow.Initializer in 'src\Operation\TensorFlow.Initializer.pas',
  TensorFlow.NnOps in 'src\Operation\NnOps\TensorFlow.NnOps.pas',
  TensorFlow.gen_nn_ops in 'src\Operation\TensorFlow.gen_nn_ops.pas',
  TensorFlow.Activation in 'src\Operation\TensorFlow.Activation.pas',
  TensorFlow.gen_ops in 'src\Operation\TensorFlow.gen_ops.pas',
  TensorFlow.Interfaces in 'src\TensorFlow.Interfaces.pas',
  TensorFlow.bitwise_ops in 'src\Operation\TensorFlow.bitwise_ops.pas',
  TensorFlow.Training in 'src\TensorFlow.Training.pas',
  TensorFlow.ControlFlowState in 'src\Operation\TensorFlow.ControlFlowState.pas',
  TensorFlow.control_flow_util in 'src\Operation\TensorFlow.control_flow_util.pas',
  TensorFlow.math_grad in 'src\Gradient\TensorFlow.math_grad.pas',
  Keras.Optimizer in 'src\Keras\Keras.Optimizer.pas',
  Keras.Utils in 'src\Keras\Keras.Utils.pas',
  Keras.KerasApi in 'src\Keras\Keras.KerasApi.pas',
  TensorFlow.resource_variable_grad in 'src\Gradient\TensorFlow.resource_variable_grad.pas',
  TensorFlow.linalg_ops in 'src\Operation\TensorFlow.linalg_ops.pas',
  TensorFlow.array_grad in 'src\Gradient\TensorFlow.array_grad.pas',
  Keras.Regularizers in 'src\Keras\Keras.Regularizers.pas',
  Keras.LossFunc in 'src\Keras\Keras.LossFunc.pas',
  Keras.Backend in 'src\Keras\Keras.Backend.pas',
  TensorFlow.image_ops_impl in 'src\Operation\TensorFlow.image_ops_impl.pas',
  TensorFlow.gen_image_ops in 'src\Operation\TensorFlow.gen_image_ops.pas',
  TensorFlow.nn_impl in 'src\Operation\TensorFlow.nn_impl.pas',
  TensorFlow.embedding_ops in 'src\Operation\TensorFlow.embedding_ops.pas',
  Keras.Data in 'src\Keras\Keras.Data.pas',
  Keras.Models in 'src\Keras\Keras.Models.pas',
  TensorFlow.dataset_ops in 'src\Operation\TensorFlow.dataset_ops.pas',
  Keras.Preprocessing in 'src\Keras\Keras.Preprocessing.pas',
  Keras.LayersApi in 'src\Keras\Keras.LayersApi.pas',
  Keras.MetricsApi in 'src\Keras\Keras.MetricsApi.pas',
  TensorFlow.tensor_array_ops in 'src\Operation\TensorFlow.tensor_array_ops.pas',
  Keras.Container in 'src\Keras\Keras.Container.pas',
  TensorFlow.nn_grad in 'src\Gradient\TensorFlow.nn_grad.pas',
  ProtoGen.Main in 'src\Proto\ProtoGen.Main.pas',
  TensorFlow.stateless_random_ops in 'src\Operation\TensorFlow.stateless_random_ops.pas',
  untModels in 'untModels.pas',
  hdf5dll in 'src\lib\hdf5dll.pas',
  Hdf5 in 'src\lib\Hdf5.pas',
  Keras.Saving in 'src\Keras\Keras.Saving.pas',
  TensorFlow.CondContext in 'src\Operation\TensorFlow.CondContext.pas',
  Keras.Callbacks in 'src\Keras\Keras.Callbacks.pas',
  Keras.Core in 'src\Keras\Keras.Core.pas',
  TensorFlow.Core in 'src\TensorFlow.Core.pas',
  TensorFlow.Proto in 'src\Proto\TensorFlow.Proto.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.










