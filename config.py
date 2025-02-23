import ollama

def get_medical_comment(body_part, diagnosis_result):
    prompt = f"""
    Doctor has just diagnosed a patient's {body_part} with {diagnosis_result}.
    Please provide a brief explanation of what it means for the patient and what the next steps should be.
    Dont give lengthy parapgraphs or points, give just 2 to 3 sentences
    """
    response = ollama.chat(
        model='qwen2.5:7b',
        messages=[{'role': 'user', 'content': prompt}]
    )
    return response['message']['content']

def get_comment(body_part):
    prompt = f"""
    Doctor has just diagnosed a patient's {body_part}.
    And the results came out normal. Give a brief comment in just 1 sentence
    """

    response = ollama.chat(
        model='qwen2.5:7b',
        messages=[{'role': 'user', 'content': prompt}]
    )
    return response['message']['content']

Name = ''
Phone = ''
Diagnoses = {
    "left_eye": {
        "diagnosis_result": "",  # e.g., Cataract / Normal
        "image": "",             # Base64 encoded image
        "comment": ""            # Assurance or medical comment
    },
    "right_eye": {
        "diagnosis_result": "",  # e.g., Cataract / Normal
        "image": "",             # Base64 encoded image
        "comment": ""            # Assurance or medical comment
    },
    "blink_rate": {
        "diagnosis_result": "",  # e.g., High / Low / Normal
        "blink_rate": 0,         # Actual blink rate (int)
        "comment": ""            # Comment based on the blink rate
    },
    "lungs": {
        "diagnosis_result": "",  # Normal / Wheezing / Crackles / Both
        "comment": ""            # Comment based on lung sound analysis
    },
    "skin1": {
        "diagnosis_result": "",  # e.g., Whitehead, Blackhead, Papule, etc.
        "image": "",             # Base64 encoded image
        "comment": ""            # Comment for skin1
    },
    "skin2": {
        "diagnosis_result": "",  # e.g., Whitehead, Blackhead, Papule, etc.
        "image": "",             # Base64 encoded image
        "comment": ""            # Comment for skin2
    }

}
