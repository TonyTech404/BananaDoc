class DeficiencyInfoProvider:
    """
    Class to provide detailed information about nutrient deficiencies
    """
    
    @staticmethod
    def get_deficiency_info(deficiency_type):
        """
        Get detailed information about a specific nutrient deficiency
        
        Args:
            deficiency_type: The type of deficiency (e.g., "Boron", "Calcium")
            
        Returns:
            Dictionary with symptoms, treatment, and prevention information
        """
        deficiency_info = {
            "Boron": {
                "symptoms": "Stunted growth, brittle, thick, and curled leaves. The leaf tips become dry and necrotic.",
                "treatment": "Apply borax or other boron fertilizers at recommended rates. Foliar spray of 0.1% to 0.25% borax solution.",
                "prevention": "Regular soil testing, maintaining proper soil pH, and adding organic matter to soil."
            },
            "Calcium": {
                "symptoms": "Young leaves are distorted with hooked tips and dead margins. The leaf lamina is reduced.",
                "treatment": "Apply calcium nitrate, calcium sulfate (gypsum) or lime. Foliar spray with calcium chloride.",
                "prevention": "Maintain proper soil pH, avoid excess potassium fertilization, ensure proper irrigation."
            },
            "Healthy": {
                "symptoms": "No symptoms of nutrient deficiency. Leaves are vibrant green with proper size and shape.",
                "treatment": "Continue with balanced fertilization and proper care.",
                "prevention": "Regular soil testing, balanced fertilization, and proper watering practices."
            },
            "Iron": {
                "symptoms": "Interveinal yellowing (chlorosis) of young leaves while veins remain green. Severe cases show whitish or pale yellow leaves.",
                "treatment": "Apply iron sulfate or iron chelates. Foliar spray with 0.5% to 1% ferrous sulfate solution.",
                "prevention": "Maintain proper soil pH (6.0-6.5), avoid waterlogging, add organic matter to soil."
            },
            "Magnesium": {
                "symptoms": "Interveinal chlorosis starting from leaf margins and progressing inward, typically on older leaves. Orange-yellow discoloration with green veins.",
                "treatment": "Apply Epsom salts (magnesium sulfate) or dolomitic limestone. Foliar spray with 2% magnesium sulfate solution.",
                "prevention": "Regular soil testing, avoid excess potassium application, maintain proper pH."
            },
            "Manganese": {
                "symptoms": "Interveinal chlorosis with a checkered pattern, usually on younger leaves. Reduced leaf size and deformed leaf edges.",
                "treatment": "Apply manganese sulfate to soil or as foliar spray (0.1% to 0.5% solution).",
                "prevention": "Maintain proper soil pH, avoid over-liming, ensure good drainage."
            },
            "Potassium": {
                "symptoms": "Chlorosis and necrosis at leaf margins of older leaves, orange-yellow color. Premature leaf fall.",
                "treatment": "Apply potassium sulfate, potassium chloride, or potassium nitrate. Foliar spray with 1-2% potassium sulfate.",
                "prevention": "Regular soil testing, balanced fertilization with NPK, add organic matter to soil."
            },
            "Sulphur": {
                "symptoms": "Uniform yellowing of younger leaves. Stunted growth and delayed fruiting.",
                "treatment": "Apply elemental sulfur, ammonium sulfate, or gypsum. Foliar spray is not very effective for sulfur.",
                "prevention": "Use sulfur-containing fertilizers periodically, add organic matter to soil."
            },
            "Zinc": {
                "symptoms": "Small, narrow leaves with interveinal chlorosis. Shortened internodes leading to rosette appearance.",
                "treatment": "Apply zinc sulfate to soil or as foliar spray (0.1% to 0.5% solution). Use zinc chelates for better absorption.",
                "prevention": "Maintain proper soil pH, avoid excessive phosphorus application, add organic matter."
            }
        }
        
        return deficiency_info.get(deficiency_type, {
            "symptoms": "Information not available",
            "treatment": "Information not available",
            "prevention": "Information not available"
        })
    
    @staticmethod
    def get_all_deficiencies():
        """
        Get a list of all deficiency types
        
        Returns:
            List of all deficiency types
        """
        return [
            "Boron", 
            "Calcium", 
            "Healthy", 
            "Iron", 
            "Magnesium", 
            "Manganese", 
            "Potassium", 
            "Sulphur", 
            "Zinc"
        ] 