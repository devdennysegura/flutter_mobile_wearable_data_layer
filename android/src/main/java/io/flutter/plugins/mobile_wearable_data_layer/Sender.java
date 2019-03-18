package io.flutter.plugins.mobile_wearable_data_layer;

import android.app.Activity;
import android.util.Log;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.wearable.Wearable;
import com.google.android.gms.wearable.Node;

import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.MethodChannel.Result;

import java.util.List;
import java.util.concurrent.ExecutionException;

class Sender extends Thread {
    private static final String TAG = "Sender";
    String path;
    String message;
    Registrar registrar;
    Result result;

    Sender(String path, String message, Registrar registrar, Result result) {
        this.path = path;
        this.message = message;
        this.registrar = registrar;
        this.result = result;
    }

    public void run() {
        try {
            Task<List<Node>> nodeListTask = Wearable.getNodeClient(this.registrar.activity()).getConnectedNodes();
            List<Node> nodes = Tasks.await(nodeListTask);
            byte[] payload = message.toString().getBytes();
            for (Node node : nodes) {
                String nodeId = node.getId();
                if (nodeId != null) {
                    Task<Integer> sendMessageTask = Wearable.getMessageClient(this.registrar.activity())
                            .sendMessage(nodeId, this.path, payload);
                    sendMessageTask.addOnCompleteListener(new OnCompleteListener<Integer>() {
                        @Override
                        public void onComplete(Task<Integer> task) {
                            if (task.isSuccessful()) {
                                result.success(true);
                            } else {
                                result.success(false);
                            }
                        }
                    });
                }

            }
        } catch (Exception exception) {
            Log.e(TAG, exception.getMessage());
        }
    }
}