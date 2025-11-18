import ReplayKit
import SwiftUI

class ScreenRecorder: ObservableObject {
    @Published var isRecording = false
    private let recorder = RPScreenRecorder.shared()
    
    func startRecording() {
        guard recorder.isAvailable else {
            print("Recording is not available")
            return
        }
        
        recorder.startRecording { [weak self] error in
            if let error = error {
                print("Error starting recording: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.isRecording = true
                }
            }
        }
    }
    
    func stopRecording(completion: @escaping (RPPreviewViewController?) -> Void) {
        recorder.stopRecording { [weak self] previewController, error in
            DispatchQueue.main.async {
                self?.isRecording = false
                if let error = error {
                    print("Error stopping recording: \(error)")
                    completion(nil)
                } else {
                    completion(previewController)
                }
            }
        }
    }
}

struct ScreenRecordingButton: View {
    @StateObject private var recorder = ScreenRecorder()
    @State private var previewController: RPPreviewViewController?
    @State private var showPreview = false
    
    var body: some View {
        Button(action: {
            if recorder.isRecording {
                recorder.stopRecording { preview in
                    if let preview = preview {
                        self.previewController = preview
                        self.showPreview = true
                    }
                }
            } else {
                recorder.startRecording()
            }
        }) {
            Image(systemName: recorder.isRecording ? "stop.circle.fill" : "video.circle")
                .foregroundStyle(recorder.isRecording ? .red : .blue)
        }
        .sheet(isPresented: $showPreview) {
            if let preview = previewController {
                ReplayKitPreview(previewController: preview)
            }
        }
    }
}

struct ReplayKitPreview: UIViewControllerRepresentable {
    let previewController: RPPreviewViewController
    
    func makeUIViewController(context: Context) -> RPPreviewViewController {
        previewController.previewControllerDelegate = context.coordinator
        return previewController
    }
    
    func updateUIViewController(_ uiViewController: RPPreviewViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, RPPreviewViewControllerDelegate {
        var parent: ReplayKitPreview
        
        init(_ parent: ReplayKitPreview) {
            self.parent = parent
        }
        
        func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
            previewController.dismiss(animated: true)
        }
    }
}
