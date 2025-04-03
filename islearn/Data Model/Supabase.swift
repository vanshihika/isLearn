//
//  Supabase.swift
//  islearn
//
//  Created by student-2 on 01/04/25.
//

import Foundation
import Supabase

class SupabaseManager {
        static let shared = SupabaseManager()
        let client: SupabaseClient

        private init() {
            client = SupabaseClient(
                supabaseURL: URL(string: "https://uuptxjfxfqfyqznwrmdh.supabase.co")!,
                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1cHR4amZ4ZnFmeXF6bndybWRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM0ODgxMjUsImV4cCI6MjA1OTA2NDEyNX0.h2Upla-35SqHonOL1R0fRiSxu1l_jQOZ4tsD9P8YDRE"
              )
        }
}
